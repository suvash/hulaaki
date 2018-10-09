defmodule Hulaaki.Client do
  @moduledoc """
  Provides a Client implementation that uses a Connection using Genserver
  with overridable callbacks for messages sent and received
  """
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer, restart: :transient
      alias Hulaaki.Connection
      alias Hulaaki.Message

      def start_link(initial_state) do
        GenServer.start_link(__MODULE__, initial_state)
      end

      def stop(pid) do
        GenServer.call(pid, :stop)
      end

      def connect(pid, opts) do
        GenServer.call(pid, {:connect, opts})
      end

      def publish(pid, opts) do
        GenServer.call(pid, {:publish, opts})
      end

      def subscribe(pid, opts) do
        GenServer.call(pid, {:subscribe, opts})
      end

      def unsubscribe(pid, opts) do
        GenServer.call(pid, {:unsubscribe, opts})
      end

      def ping(pid) do
        GenServer.call(pid, :ping)
      end

      def disconnect(pid) do
        GenServer.call(pid, :disconnect)
      end

      ## GenServer callbacks

      def init(%{} = state) do
        state =
          state
          |> Map.put(:packet_id, 1)
          |> Map.put(:keep_alive_interval, nil)
          |> Map.put(:keep_alive_timer_ref, nil)
          |> Map.put(:ping_response_timeout_interval, nil)
          |> Map.put(:ping_response_timer_ref, nil)
          |> Map.put(:connection, nil)

        {:ok, state}
      end

      def handle_call(:stop, _from, state) do
        case state.connection do
          nil ->
            nil

          conn_pid ->
            Connection.stop(conn_pid)
            Supervisor.delete_child(Connection.Supervisor, state.client_id)
        end

        {:stop, :normal, :ok, state}
      end

      # collection options for host port ?

      def handle_call({:connect, opts}, _from, state) do
        host = opts |> Keyword.fetch!(:host)
        port = opts |> Keyword.fetch!(:port)
        timeout = opts |> Keyword.get(:timeout, 10 * 1000)
        ssl = opts |> Keyword.get(:ssl, false)
        transport = opts |> Keyword.get(:transport)
        transport_opts = opts |> Keyword.get(:transport_opts)

        client_id = opts |> Keyword.fetch!(:client_id)
        username = opts |> Keyword.get(:username, "")
        password = opts |> Keyword.get(:password, "")
        will_topic = opts |> Keyword.get(:will_topic, "")
        will_message = opts |> Keyword.get(:will_message, "")
        will_qos = opts |> Keyword.get(:will_qos, 0)
        will_retain = opts |> Keyword.get(:will_retain, 0)
        clean_session = opts |> Keyword.get(:clean_session, 1)
        keep_alive = opts |> Keyword.get(:keep_alive, 100)

        # arbritary : based off recommendation on MQTT 3.1.1 spec Line 542/543
        ping_response_timeout = keep_alive * 2

        message =
          Message.connect(
            client_id,
            username,
            password,
            will_topic,
            will_message,
            will_qos,
            will_retain,
            clean_session,
            keep_alive
          )

        {:ok, conn_pid} = start_connection(client_id)

        Process.monitor(conn_pid)

        state = Map.merge(state, %{connection: conn_pid, client_id: client_id})

        connect_opts = [
          host: host,
          port: port,
          timeout: timeout,
          ssl: ssl,
          transport: transport,
          transport_opts: transport_opts
        ]

        case state.connection |> Connection.connect(message, connect_opts) do
          :ok ->
            {:reply, :ok,
             %{
               state
               | keep_alive_interval: keep_alive * 1000,
                 ping_response_timeout_interval: ping_response_timeout * 1000
             }}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end
      end

      def handle_call(_, _from, %{connection: nil} = state) do
        {:reply, {:error, :not_connected}, state}
      end

      def handle_call({:publish, opts}, _from, state) do
        topic = opts |> Keyword.fetch!(:topic)
        msg = opts |> Keyword.fetch!(:message)
        dup = opts |> Keyword.fetch!(:dup)
        qos = opts |> Keyword.fetch!(:qos)
        retain = opts |> Keyword.fetch!(:retain)

        {message, state} =
          case qos do
            0 ->
              {Message.publish(topic, msg, dup, qos, retain), state}

            _ ->
              id = state.packet_id
              state = update_packet_id(state)
              {Message.publish(id, topic, msg, dup, qos, retain), state}
          end

        :ok = state.connection |> Connection.publish(message)
        {:reply, :ok, state}
      end

      def handle_call({:subscribe, opts}, _from, state) do
        id = state.packet_id
        topics = opts |> Keyword.fetch!(:topics)
        qoses = opts |> Keyword.fetch!(:qoses)

        message = Message.subscribe(id, topics, qoses)

        :ok = state.connection |> Connection.subscribe(message)
        state = update_packet_id(state)
        {:reply, :ok, state}
      end

      def handle_call({:unsubscribe, opts}, _from, state) do
        id = state.packet_id
        topics = opts |> Keyword.fetch!(:topics)

        message = Message.unsubscribe(id, topics)

        :ok = state.connection |> Connection.unsubscribe(message)
        state = update_packet_id(state)
        {:reply, :ok, state}
      end

      def handle_call(:ping, _from, state) do
        :ok = state.connection |> Connection.ping()
        {:reply, :ok, state}
      end

      def handle_call(:disconnect, _from, state) do
        :ok = state.connection |> Connection.disconnect()
        {:reply, :ok, state}
      end

      def handle_info({:sent, %Message.Connect{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_connect(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.ConnAck{} = message}, state) do
        on_connect_ack(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:sent, %Message.Publish{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_publish(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.Publish{qos: qos} = message}, state) do
        on_subscribed_publish(message: message, state: state)

        case qos do
          1 ->
            message = Message.publish_ack(message.id)
            :ok = state.connection |> Connection.publish_ack(message)

          _ ->
            # unsure about supporting qos 2 yet
            :noop
        end

        {:noreply, state}
      end

      def handle_info({:sent, %Message.PubAck{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_subscribed_publish_ack(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.PubRec{} = message}, state) do
        on_publish_receive(message: message, state: state)

        message = Message.publish_release(message.id)
        :ok = state.connection |> Connection.publish_release(message)

        {:noreply, state}
      end

      def handle_info({:sent, %Message.PubRel{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_publish_release(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.PubComp{} = message}, state) do
        on_publish_complete(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.PubAck{} = message}, state) do
        on_publish_ack(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:sent, %Message.Subscribe{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_subscribe(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.SubAck{} = message}, state) do
        on_subscribe_ack(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:sent, %Message.Unsubscribe{} = message}, state) do
        state = reset_keep_alive_timer(state)
        on_unsubscribe(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.UnsubAck{} = message}, state) do
        on_unsubscribe_ack(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:sent, %Message.PingReq{} = message}, state) do
        state = reset_keep_alive_timer(state)
        state = reset_ping_response_timer(state)
        on_ping(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:received, %Message.PingResp{} = message}, state) do
        state = cancel_ping_response_timer(state)
        on_ping_response(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:sent, %Message.Disconnect{} = message}, state) do
        state = cancel_keep_alive_timer(state)
        on_disconnect(message: message, state: state)
        {:noreply, state}
      end

      def handle_info({:keep_alive}, state) do
        :ok = state.connection |> Connection.ping()
        {:noreply, state}
      end

      def handle_info({:ping_response_timeout}, state) do
        on_ping_response_timeout(message: nil, state: state)
        {:noreply, state}
      end

      def handle_info({:connection_down, reason}, state) do
        state = cancel_keep_alive_timer(state)
        on_connection_down(reason: reason, state: state)
        {:noreply, state}
      end

      def handle_info(
            {:DOWN, _, :process, conn_pid, reason},
            %{connection: conn_pid, client_id: client_id} = state
          ) do
        state = cancel_keep_alive_timer(state)
        Supervisor.delete_child(Connection.Supervisor, client_id)
        on_connection_down(reason: reason, state: state)
        {:noreply, state}
      end

      ## Private functions
      defp reset_keep_alive_timer(
             %{
               keep_alive_interval: keep_alive_interval,
               keep_alive_timer_ref: keep_alive_timer_ref
             } = state
           ) do
        if keep_alive_timer_ref, do: Process.cancel_timer(keep_alive_timer_ref)
        keep_alive_timer_ref = Process.send_after(self(), {:keep_alive}, keep_alive_interval)
        %{state | keep_alive_timer_ref: keep_alive_timer_ref}
      end

      defp reset_ping_response_timer(
             %{
               ping_response_timeout_interval: ping_response_timeout_interval,
               ping_response_timer_ref: ping_response_timer_ref
             } = state
           ) do
        if ping_response_timer_ref, do: Process.cancel_timer(ping_response_timer_ref)

        ping_response_timer_ref =
          Process.send_after(self(), {:ping_response_timeout}, ping_response_timeout_interval)

        %{state | ping_response_timer_ref: ping_response_timer_ref}
      end

      defp cancel_keep_alive_timer(%{keep_alive_timer_ref: keep_alive_timer_ref} = state) do
        if keep_alive_timer_ref, do: Process.cancel_timer(keep_alive_timer_ref)
        %{state | keep_alive_timer_ref: nil}
      end

      defp cancel_ping_response_timer(%{ping_response_timer_ref: ping_response_timer_ref} = state) do
        if ping_response_timer_ref, do: Process.cancel_timer(ping_response_timer_ref)
        %{state | ping_response_timer_ref: nil}
      end

      defp update_packet_id(%{packet_id: 65_535} = state) do
        %{state | packet_id: 1}
      end

      defp update_packet_id(%{packet_id: packet_id} = state) do
        %{state | packet_id: packet_id + 1}
      end

      defp start_connection(client_id) do
        child_spec = %{
          id: client_id,
          start: {Connection, :start_link, [self()]},
          restart: :transient
        }

        case Supervisor.start_child(Connection.Supervisor, child_spec) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
        end
      end

      ## Overrideable callbacks

      def on_connect(message: message, state: state), do: true
      def on_connect_ack(message: message, state: state), do: true
      def on_publish(message: message, state: state), do: true
      def on_publish_receive(message: message, state: state), do: true
      def on_publish_release(message: message, state: state), do: true
      def on_publish_complete(message: message, state: state), do: true
      def on_publish_ack(message: message, state: state), do: true
      def on_subscribe(message: message, state: state), do: true
      def on_subscribe_ack(message: message, state: state), do: true
      def on_unsubscribe(message: message, state: state), do: true
      def on_unsubscribe_ack(message: message, state: state), do: true
      def on_subscribed_publish(message: message, state: state), do: true
      def on_subscribed_publish_ack(message: message, state: state), do: true
      def on_ping(message: message, state: state), do: true
      def on_ping_response(message: message, state: state), do: true
      def on_ping_response_timeout(message: message, state: state), do: true
      def on_disconnect(message: message, state: state), do: true
      def on_connection_down(reason: reason, state: state), do: true

      defoverridable on_connect: 1,
                     on_connect_ack: 1,
                     on_publish: 1,
                     on_publish_ack: 1,
                     on_publish_receive: 1,
                     on_publish_release: 1,
                     on_publish_complete: 1,
                     on_subscribe: 1,
                     on_subscribe_ack: 1,
                     on_unsubscribe: 1,
                     on_unsubscribe_ack: 1,
                     on_subscribed_publish: 1,
                     on_subscribed_publish_ack: 1,
                     on_ping: 1,
                     on_ping_response: 1,
                     on_ping_response_timeout: 1,
                     on_disconnect: 1,
                     on_connection_down: 1
    end
  end
end
