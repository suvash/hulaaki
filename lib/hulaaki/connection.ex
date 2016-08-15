defmodule Hulaaki.Connection do
  use GenServer
  alias Hulaaki.Message
  alias Hulaaki.Packet
  @moduledoc """
  Provides a GenServer process that is responsible for sending and
  receving message to/from an MQTT broker over a tcp connection
  """

  @doc """
  Start the Genserver process with a pid that intends to
  use the connection
  """
  def start_link(client_pid)
  when is_pid(client_pid) do
    GenServer.start_link(__MODULE__, %{client: client_pid, socket: nil, transport: nil})
  end

  @doc """
  Sends a Connect message over the connection (with options)
  """
  def connect(pid, %Message.Connect{} = message, opts) do
    GenServer.call(pid, {:connect, message, opts})
  end

  @doc """
  Sends a Publish message over the connection
  """
  def publish(pid, %Message.Publish{} = message) do
    GenServer.call(pid, {:publish, message})
  end

  @doc """
  Sends a Publish Ack message over the connection
  """
  def publish_ack(pid, %Message.PubAck{} = message) do
    GenServer.call(pid, {:publish_ack, message})
  end

  @doc """
  Sends a Publish release message over the connection
  """
  def publish_release(pid, %Message.PubRel{} = message) do
    GenServer.call(pid, {:publish_release, message})
  end

  @doc """
  Sends a Subscribe message over the connection
  """
  def subscribe(pid, %Message.Subscribe{} = message) do
    GenServer.call(pid, {:subscribe, message})
  end

  @doc """
  Sends an Unsubscribe message over the connection
  """
  def unsubscribe(pid, %Message.Unsubscribe{} = message) do
    GenServer.call(pid, {:unsubscribe, message})
  end

  @doc """
  Sends a Ping message over the connection
  """
  def ping(pid, %Message.PingReq{} = message \\ Message.ping_request) do
    GenServer.call(pid, {:ping, message})
  end

  @doc """
  Sends a Disconnect message over the connection
  """
  def disconnect(pid, %Message.Disconnect{} = message \\ Message.disconnect ) do
    GenServer.call(pid, {:disconnect, message})
  end

  @doc """
  Stops the Genserver process
  """
  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  ## GenServer callbacks

  @doc false
  def init(state) do
    state = state |> Map.put(:remainder, "")
    {:ok, state}
  end

  @doc false
  def handle_call(:stop, _from, state) do
    close_socket(state.transport, state.socket)
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_call({:connect, message, opts}, _from, state) do
    case open_socket(opts) do
      %{socket: socket, transport: transport} ->
                           dispatch_message(transport, socket, message)
                           Kernel.send state.client, {:sent, message}
                           {:reply, :ok, %{state | socket: socket, transport: transport}}
       {:error, reason} -> {:reply, {:error, reason}, state}
    end

  end

  @doc false
  def handle_call({_, message}, _from, state) do
    dispatch_message(state.transport, state.socket, message)
    Kernel.send state.client, {:sent, message}
    {:reply, :ok, state}
  end

  @doc false
  def handle_info({:tcp, socket, data}, state) do
    handle_socket_data(socket, data, state)
  end

  @doc false
  def handle_info({:ssl, socket, data}, state) do
    handle_socket_data(socket, data, state)
  end

  @doc false
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :shutdown, state}
  end

  @doc false
  def handle_info({:ssl_closed, _socket}, state) do
    {:stop, :shutdown, state}
  end

  defp handle_socket_data(socket, data, state) do
    set_active_once(socket, state.transport)
    {messages, remainder} = decode_packets(state.remainder <> data)

    Enum.each(messages,
      fn(message) ->
        Kernel.send state.client, {:received, message}
      end
    )
    state = %{state | remainder: remainder}
    {:noreply, state}
  end

  defp decode_packets(data) do
    decode_packets(data, [])
  end

  defp decode_packets(data, accumulator) do
    %{message: message, remainder: remainder} = Packet.decode(data)

    case {message, remainder} do
      {nil, _} -> {Enum.reverse(accumulator), remainder}
      {_, ""} -> {Enum.reverse([message | accumulator]), ""}
      _ -> decode_packets(remainder, [message | accumulator])
    end
  end

  defp dispatch_message(transport, socket, message) do
    packet = Packet.encode(message)
    socket |> set_active_once(transport) |> transport.send(packet)
  end

  defp set_active_once(socket, transport) do
    case transport do
      :ssl -> :ssl.setopts(socket, active: :once)
      :gen_tcp -> :inet.setopts(socket, active: :once)
    end
    socket
  end

  defp open_socket(opts) do
    timeout  = opts |> Keyword.fetch!(:timeout)
    host     = opts |> Keyword.fetch!(:host)
    host     = if is_binary(host), do: String.to_charlist(host), else: host
    port     = opts |> Keyword.fetch!(:port)
    ssl      = opts |> Keyword.fetch!(:ssl)

    tcp_opts = [:binary, {:active, :once}, {:packet, :raw}]

    {transport, socket_opts} =
      case ssl do
        false -> {:gen_tcp, tcp_opts}
        true -> {:ssl, tcp_opts}
        ssl_opts -> {:ssl, tcp_opts ++ ssl_opts}
      end

    case transport.connect(host, port, socket_opts, timeout) do
      {:ok, socket} -> %{transport: transport, socket: socket}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unknown}
    end
  end

  defp close_socket(transport, socket) do
    socket |> transport.close
  end

end
