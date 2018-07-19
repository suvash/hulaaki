defmodule Hulaaki.WebSocket do
  use GenServer
  require Socket
  @behaviour Hulaaki.Transport

  def connect(host, port, opts, timeout) do
    conn = self()
    secure = opts |> Keyword.get(:secure, false)
    path = opts |> Keyword.get(:path, "/")

    {:ok, sw} =
      Socket.Web.connect(
        {to_string(host), port},
        secure: secure,
        path: path,
        protocol: ["mqttv3.1"]#["mqtt"]
      )

    {:ok, pid} = start_link(%{sw: sw, conn: conn})
    {:ok, %{sw: sw, pid: pid, conn: conn}}
  end

  def send(%{sw: sw} = socket, packet) do
    :ok = Socket.Web.send(sw, {:binary, packet})
  end

  def close(%{sw: sw} = socket) do
    Socket.Web.close(sw)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    GenServer.cast(self(), :receive)
    {:ok, state |> Map.put(:pid, self())}
  end

  def handle_cast(:receive, %{sw: sw, conn: conn} = state) do
    case Socket.Web.recv(sw) do
      {:ok, {:binary, bitstring}} ->
        IO.puts("Received.....")
        Kernel.send(conn, {:tcp, state, bitstring})
        GenServer.cast(self(), :receive)
        {:noreply, state}

      {:ok, {:close, _, _}} ->
          Kernel.send(conn, {:tcp_closed, state})
          {:stop, :shutdown, state}
      other ->
        IO.inspect(other)
    end

  end
end
