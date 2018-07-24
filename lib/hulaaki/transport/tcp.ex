defmodule Hulaaki.Transport.Tcp do
  def connect(host, port, opts, timeout) do
    :gen_tcp.connect(host, port, opts, timeout)
  end

  def send(socket, packet) do
    :gen_tcp.send(socket, packet)
  end

  def close(socket) do
    :gen_tcp.close(socket)
  end

  def set_active_once(socket) do
    :inet.setopts(socket, active: :once)
    socket
  end

  def packet_message, do: :tcp
  def closing_message, do: :tcp_closed
end
