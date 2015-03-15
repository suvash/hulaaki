defmodule Hulaaki.Connection do
  use GenServer
  alias Hulaaki.Message
  alias Hulaaki.Packet

  defmodule ConnectOptions do
    defstruct [:host, :port]

    def build(host, port)
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

  defp default_connect_opts do
    host = "localhost"
    port = 1883

    ConnectOptions.build(host, port)
  end

  def connect(pid, %Message.Connect{} = message,
              %ConnectOptions{} = connect_opts \\ default_connect_opts) do
    GenServer.call(pid, {:connect, message, connect_opts})
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  ## GenServer callbacks

  def init(%State{} = state) do
    {:ok, %{state | socket: nil} }
  end

  def handle_call({:connect, message, opts}, _from, state) do
    %{socket: socket} = open_tcp_socket(opts)
    dispatch_connect(socket, message)
    {:reply, :ok, %{state | socket: socket} }
  end

  def handle_call(:stop, _from, state) do
    dispatch_disconnect(state.socket)
    {:stop, :normal, :ok, state}
  end

  def handle_info({:tcp, _, packet}, state) do
    message = Packet.decode(packet)
    send state.client, message
    {:noreply, state}
  end

  defp open_tcp_socket(opts) do
    timeout  = 100
    host     = opts.host
    port     = opts.port
    tcp_opts = [{:active, :true}, {:packet, :raw}, :binary]

    {:ok, socket} = :gen_tcp.connect(host, port, tcp_opts, timeout)

    %{socket: socket}
  end

  def dispatch_connect(socket, %Message.Connect{} = message) do
    socket |> send_message message
  end

  def dispatch_disconnect(socket, %Message.Disconnect{} = message \\ Message.disconnect) do
    socket |> send_message message
  end

  defp send_message(socket, message) do
    packet = Packet.encode(message)
    socket |> :gen_tcp.send packet
  end
end
