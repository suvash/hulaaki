defmodule Hulaaki.Transport.WebSocket.Helper do
  def init(conn, _, _, _), do: conn

  def handle({:binary, packet}, conn) do
    send(conn, {:websocket, conn, packet})
    conn
  end
end
