defmodule Hulaaki.Transport.WebSocket do
  use GenServer
  require Socket
  @behaviour Hulaaki.Transport

  @default_opts [path: "/", protocol: ["mqtt"]]

  def connect(host, port, opts, timeout) do
    with conn <- self(),
         {:ok, ws} <-
           Socket.Web.connect(
             {to_string(host), port},
             Keyword.new(@default_opts ++ opts ++ [timeout: timeout])
           ),
         socket <- %{ws: ws, conn: conn, pid: nil},
         {:ok, pid} <- start_link(socket) do
      Process.monitor(pid)
      {:ok, %{socket | pid: pid}}
    else
      {:error, "connection refused"} -> {:error, :econnrefused}
      err -> err
    end
  end

  def send(%{ws: ws, pid: pid} = _socket, packet) do
    case Socket.Web.send(ws, {:binary, packet}) do
      :ok ->
        :ok

      {:error, :closed} ->
        GenServer.stop(pid, :normal)
        {:error, :closed}
    end
  end

  def close(%{ws: ws, pid: pid} = _socket) do
    :ok = GenServer.stop(pid, :normal)
    Socket.Web.close(ws)
  end

  def set_active_once(socket), do: socket

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    GenServer.cast(self(), :receive)
    {:ok, %{state | pid: self()}}
  end

  def handle_cast(:receive, %{ws: ws, conn: conn} = state) do
    case Socket.Web.recv(ws) do
      {:ok, {:binary, bitstring}} ->
        Kernel.send(conn, {packet_message(), state, bitstring})
        GenServer.cast(self(), :receive)
        {:noreply, state}

      {:ok, {:close, _, _}} ->
        Kernel.send(conn, {closing_message(), state})
        {:noreply, state}

      error ->
        {:stop, error, state}
    end
  end

  def handle_info({:EXIT, _, reason}, %{ws: ws} = state) do
    Socket.Web.close(ws)
    {:stop, {:shutdown, reason}, state}
  end

  def packet_message, do: :websocket
  def closing_message, do: :websocket_closed
end
