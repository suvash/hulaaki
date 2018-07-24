defmodule Hulaaki.Transport.Ssl do
  def connect(host, port, opts, timeout) do
    :ssl.connect(host, port, opts, timeout)
  end

  def send(socket, packet) do
    :ssl.send(socket, packet)
  end

  def close(socket) do
    :ssl.close(socket)
  end

  def set_active_once(socket) do
    :ssl.setopts(socket, active: :once)
    socket
  end

  def packet_message, do: :ssl
  def closing_message, do: :ssl_closed
end
