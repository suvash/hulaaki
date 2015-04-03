defmodule Hulaaki.Client do
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer
      alias Hulaaki.Connection
      alias Hulaaki.Message

      def start_link(initial_state) do
        {:ok, connection_pid} = Connection.start_link(self())
        state = Map.merge(%{connection: connection_pid}, initial_state)

        GenServer.start_link(__MODULE__, state)
      end

      def stop(pid) do
        GenServer.call pid, :stop
      end

      def connect(pid, opts) do
        GenServer.call pid, {:connect, opts}
      end

      def ping(pid) do
        GenServer.call pid, :ping
      end

      def disconnect(pid) do
        GenServer.call pid, :disconnect
      end

      ## Overrideable callbacks

      def on_connect(options)
      def on_connect_ack(options)
      def on_ping(options)
      def on_pong(options)
      def on_disconnect(options)

      defoverridable [on_connect: 1, on_connect_ack: 1,
                      on_ping: 1,    on_pong: 1,
                      on_disconnect: 1]

      ## GenServer callbacks

      def init(%{} = state) do
        {:ok, state}
      end

      def handle_call(:stop, _from, state) do
        {:stop, :normal, :ok, state}
      end

      # collection options for host port ?

      def handle_call({:connect, opts}, _from, state) do
        client_id     = opts |> Keyword.fetch! :client_id
        username      = opts |> Keyword.get :username, ""
        password      = opts |> Keyword.get :password, ""
        will_topic    = opts |> Keyword.get :will_topic, ""
        will_message  = opts |> Keyword.get :will_message, ""
        will_qos      = opts |> Keyword.get :will_qos, 0
        will_retain   = opts |> Keyword.get :will_retain, 0
        clean_session = opts |> Keyword.get :clean_session, 1
        keep_alive    = opts |> Keyword.get :keep_alive, 100

        message = Message.connect(client_id, username, password,
                                  will_topic, will_message, will_qos,
                                  will_retain, clean_session, keep_alive)

        :ok = state.connection |> Connection.connect message
        on_connect [state: state]

        {:reply, :ok, state}
      end

      def handle_info(%Message.ConnAck{} = message, state) do
        on_connect_ack [message: message, state: state]

        {:noreply, state}
      end

      def handle_call(:ping, _from, state) do
        :ok = state.connection |> Connection.ping
        on_ping [state: state]

        {:reply, :ok, state}
      end

      def handle_info(%Message.PingResp{} = message, state) do
        on_pong [message: message, state: state]

        {:noreply, state}
      end

      def handle_call(:disconnect, _from, state) do
        :ok = state.connection |> Connection.disconnect
        on_disconnect [state: state]

        {:reply, :ok, state}
      end
    end
  end
end
