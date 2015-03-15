defmodule Hulaaki.Connection do
  use GenServer
  alias Hulaaki.Message
  alias Hulaaki.Packet

  defmodule ConnectOptions do
    defstruct [:host, :port, :message]

    def build(host, port, %Message.Connect{} = message)
    when ( is_binary(host) or is_list(host) )
    and is_integer(port) do
      host = if is_binary(host), do: String.to_char_list(host), else: host
      %ConnectOptions{host: host, port: port, message: message}
    end
  end

  defmodule State do
    defstruct [:socket, :client]
  end

  def start_link(client_pid)
  when is_pid(client_pid) do
    GenServer.start_link(__MODULE__, %State{client: client_pid})
  end

  defp default_connect_opts do
    host = "localhost"
    port = 1883
    message = Message.connect("default-client", "", "", "", "", 0, 0, 0, 100)

    ConnectOptions.build(host, port, message)
  end

  def connect(pid, %ConnectOptions{} = connect_opts \\ default_connect_opts) do
    GenServer.call(pid, {:connect, connect_opts})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  ## GenServer callbacks

  def init(%State{} = state) do
    {:ok, %{state | socket: nil} }
  end

  def handle_call({:connect, opts}, _from, state) do
    %{socket: socket} = connect_socket(opts)
    {:reply, :ok, %{state | socket: socket} }
  end

  def handle_call(:stop, _from, state) do
    disconnect(state.socket)
    {:stop, :normal, :ok, state}
  end

  def handle_info({:tcp, _, packet}, state) do
    message = Packet.decode(packet)
    send state.client, message
    {:noreply, state}
  end

  defp connect_socket(opts) do
    timeout  = 100
    host     = opts.host
    port     = opts.port
    message  = opts.message
    tcp_opts = [{:active, :true}, {:packet, :raw}, :binary]

    {:ok, socket} = :gen_tcp.connect(host, port, tcp_opts, timeout)

    socket |> send_message message

    %{socket: socket}
  end

  def disconnect(socket, %Message.Disconnect{} = message \\ Message.disconnect) do
    socket |> send_message message
  end

  defp send_message(socket, message) do
    packet = Packet.encode(message)
    socket |> :gen_tcp.send packet
  end
end
