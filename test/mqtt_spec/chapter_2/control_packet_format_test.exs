defmodule MQTTSpec.Chapter2.ControlPacketFormatTest do
  use ExUnit.Case
  alias Hulaaki.Message
  alias Hulaaki.Packet

  test "2.3.1-5 publish packet must not contain packet id if qos is 0" do
    dup = 1
    qos = 0
    retain = 0
    topic = "a/b"
    message = Message.publish(topic, "test", dup, qos, retain)
    round_trip = message |> Packet.encode |> Packet.decode

    assert round_trip.message.id == nil
  end

end
