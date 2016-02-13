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
    GenServer.start_link(__MODULE__, %{client: client_pid, socket: nil})
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
    {:ok, state}
  end

  @doc false
  def handle_call(:stop, _from, state) do
    close_tcp_socket(state.socket)
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_call({:connect, message, opts}, _from, state) do
    %{socket: socket} = open_tcp_socket(opts)
    dispatch_message(socket, message)
    Kernel.send state.client, {:sent, message}
    {:reply, :ok, %{state | socket: socket} }
  end

  @doc false
  def handle_call({_, message}, _from, state) do
    dispatch_message(state.socket, message)
    Kernel.send state.client, {:sent, message}
    {:reply, :ok, state}
  end

  @doc false
  def handle_info({:tcp, socket, data}, state) do
    :inet.setopts(socket, active: :once)
    messages = decode_packets(data)
    messages |> Enum.each fn(message) ->
      Kernel.send state.client, {:received, message}
    end
    {:noreply, state}
  end

  @doc false
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :shutdown, state}
  end

  defp decode_packets(data) do
    decode_packets(data, [])
  end

  defp decode_packets(data, accumulator) do
    %{message: message, remainder: remainder} = Packet.decode(data)

    case remainder do
      "" -> Enum.reverse [ message | accumulator ]
      _  -> decode_packets(remainder, [ message | accumulator ])
    end
  end

  defp open_tcp_socket(opts) do
    timeout  = 1000
    host     = opts |> Keyword.fetch! :host
    host     = if is_binary(host), do: String.to_char_list(host), else: host
    port     = opts |> Keyword.fetch! :port
    tcp_opts = [:binary, {:active, :once}, {:packet, :raw}]

    {:ok, socket} = :gen_tcp.connect(host, port, tcp_opts, timeout)

    %{socket: socket}
  end

  defp close_tcp_socket(socket) do
    socket |> :gen_tcp.close
  end

  defp dispatch_message(socket, message) do
    packet = Packet.encode(message)
    :inet.setopts(socket, active: :once)
    socket |> :gen_tcp.send packet
  end

end
