defmodule Hulaaki.Client do
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet
  alias Socket.TCP, as: TCP
  alias Socket.Stream, as: Stream

  defmodule Connection do
    defstruct [:address, :port, :client_id, :socket]
  end

  def connect(address, port, client_id)
  when is_binary(address)
  and  is_integer(port)
  and  is_binary(client_id) do
    connect = Message.connect(client_id, "","","","",0,0,0,600)
    connect_packet = Packet.encode(connect)

    socket = TCP.connect! address, port
    socket |> send_and_receive_connack connect_packet

    %Connection{address: address, port: port, client_id: client_id, socket: socket}
  end

  defp send_and_receive_connack(socket, packet) do
    %Message.ConnAck{} = socket |> send_and_receive packet
  end

  defp send_and_receive(socket, packet) do
    socket |> Stream.send! packet
    received_packet = socket |> Stream.recv!
    Packet.decode(received_packet)
  end
end
