defmodule Hulaaki.Connection do
  use GenServer
  alias Hulaaki.Message
  alias Hulaaki.Packet

  defmodule ConnectOptions do
    defstruct [:host, :port]

    def build(host \\ "localhost", port \\ 1883)
    when ( is_binary(host) or is_list(host) )
    and is_integer(port) do
      host = if is_binary(host), do: String.to_char_list(host), else: host
      %ConnectOptions{host: host, port: port}
    end
  end

  defmodule State do
    defstruct [:socket, :client]
  end

  def start_link(client_pid)
  when is_pid(client_pid) do
    GenServer.start_link(__MODULE__, %State{client: client_pid})
  end

  def connect(pid, %Message.Connect{} = message,
              %ConnectOptions{} = connect_opts \\ ConnectOptions.build) do
    GenServer.call(pid, {:connect, message, connect_opts})
  end

  def publish(pid, %Message.Publish{} = message) do
    GenServer.call(pid, {:publish, message})
  end

  def publish_release(pid, %Message.PubRel{} = message) do
    GenServer.call(pid, {:publish_release, message})
  end

  def subscribe(pid, %Message.Subscribe{} = message) do
    GenServer.call(pid, {:subscribe, message})
  end

  def unsubscribe(pid, %Message.Unsubscribe{} = message) do
    GenServer.call(pid, {:unsubscribe, message})
  end

  def ping(pid, %Message.PingReq{} = message \\ Message.ping_request) do
    GenServer.call(pid, {:ping, message})
  end

  def disconnect(pid, %Message.Disconnect{} = message \\ Message.disconnect ) do
    GenServer.call(pid, {:disconnect, message})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  ## GenServer callbacks

  def init(%State{} = state) do
    {:ok, %{state | socket: nil} }
  end

  def handle_call(:stop, _from, state) do
    close_tcp_socket(state.socket)
    {:stop, :normal, :ok, state}
  end

  def handle_call({:connect, message, opts}, _from, state) do
    %{socket: socket} = open_tcp_socket(opts)

    recv_message = %Message.ConnAck{} = socket |> dispatch_and_receive message
    send state.client, recv_message

    {:reply, :ok, %{state | socket: socket} }
  end

  def handle_call({:publish, message}, _from, state) do
    recv_message = state.socket |> dispatch_and_receive message
    case recv_message do
      %Message.PubAck{} ->
        send state.client, recv_message
      %Message.PubRec{} ->
        send state.client, recv_message
    end

    {:reply, :ok, state}
  end

  def handle_call({:publish_release, message}, _from, state) do
    recv_message = %Message.PubComp{} = state.socket |> dispatch_and_receive message
    send state.client, recv_message

    {:reply, :ok, state}
  end

  def handle_call({:subscribe, message}, _from, state) do
    recv_message = %Message.SubAck{} = state.socket |> dispatch_and_receive message
    send state.client, recv_message

    {:reply, :ok, state}
  end

  def handle_call({:unsubscribe, message}, _from, state) do
    recv_message = %Message.UnsubAck{} = state.socket |> dispatch_and_receive message
    send state.client, recv_message

    {:reply, :ok, state}
  end

  def handle_call({:ping, message}, _from, state) do
    recv_message = %Message.PingResp{} = state.socket |> dispatch_and_receive message
    send state.client, recv_message

    {:reply, :ok, state}
  end

  def handle_call({:disconnect, message}, _from, state) do
    dispatch(state.socket, message)
    {:reply, :ok, state}
  end

  def handle_info({:tcp, socket, packet}, state) do
    message = Packet.decode(packet)
    send state.client, message
    :inet.setopts(socket, active: :once)
    {:noreply, state}
  end

  defp open_tcp_socket(opts) do
    timeout  = 100
    host     = opts.host
    port     = opts.port
    tcp_opts = [:binary, {:active, :false}, {:packet, :raw}]

    {:ok, socket} = :gen_tcp.connect(host, port, tcp_opts, timeout)

    %{socket: socket}
  end

  defp close_tcp_socket(socket) do
    socket |> :gen_tcp.close
  end

  defp dispatch_and_receive(socket, message) do
    send_packet = Packet.encode(message)

    :inet.setopts(socket, active: :false)
    socket |> :gen_tcp.send send_packet

    {:ok, received_packet} = socket |> :gen_tcp.recv 0
    :inet.setopts(socket, active: :once)

    Packet.decode(received_packet)
  end

  defp dispatch(socket, message) do
    packet = Packet.encode(message)
    socket |> :gen_tcp.send packet
    :inet.setopts(socket, active: :once)
  end

end
