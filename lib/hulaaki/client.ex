defmodule Hulaaki.Client do
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet
  alias Socket.TCP, as: TCP
  alias Socket.Stream, as: Stream

  defmodule Connection do
    defstruct [:address, :port, :client_id, :socket]
  end

  def connect(address, port, %Message.Connect{} = message)
  when is_binary(address)
  and  is_integer(port) do
    socket = TCP.connect! address, port
    socket |> send_and_receive_connack message
    # all 5 cases to be handled, only happy path so far

    client_id = message.client_id

    %Connection{address: address, port: port, client_id: client_id, socket: socket}
  end

  defp send_and_receive_connack(socket, message) do
    %Message.ConnAck{} = socket |> send_and_receive message
  end

  def publish(socket, %Message.Publish{qos: 2} = message) do
    socket |> send_and_receive_publish_receive message

    publish_release_message = Message.publish_release(message.id)

    socket |> send_and_receive_publish_complete publish_release_message
  end

  def publish(socket, %Message.Publish{} = message) do
    socket |> send_and_receive_publish_ack message
  end

  defp send_and_receive_publish_ack(socket, message) do
    %Message.PubAck{} = socket |> send_and_receive message
  end

  defp send_and_receive_publish_receive(socket, message) do
    %Message.PubRec{} = socket |> send_and_receive message
  end

  defp send_and_receive_publish_complete(socket, message) do
    %Message.PubComp{} = socket |> send_and_receive message
  end

  def subscribe(socket, %Message.Subscribe{} = message) do
    socket |> send_and_receive_subscribe_ack message
  end

  defp send_and_receive_subscribe_ack(socket, message) do
    %Message.SubAck{} = socket |> send_and_receive message
  end

  def unsubscribe(socket, %Message.Unsubscribe{} = message) do
    socket |> send_and_receive_unsubscribe_ack message
  end

  defp send_and_receive_unsubscribe_ack(socket, message) do
    %Message.UnsubAck{} = socket |> send_and_receive message
  end

  def ping(socket, %Message.PingReq{} = message \\ Message.ping_request) do
    socket |> send_and_receive_ping_response message
  end

  defp send_and_receive_ping_response(socket, message) do
    %Message.PingResp{} = socket |> send_and_receive message
  end

  def disconnect(socket, %Message.Disconnect{} = message \\ Message.disconnect) do
    socket |> send_no_receive message
  end

  defp send_no_receive(socket, message) do
    send_packet = Packet.encode(message)
    socket |> Stream.send! send_packet
  end

  defp send_and_receive(socket, message) do
    send_packet = Packet.encode(message)
    socket |> Stream.send! send_packet
    received_packet = socket |> Stream.recv!
    Packet.decode(received_packet)
  end
end
