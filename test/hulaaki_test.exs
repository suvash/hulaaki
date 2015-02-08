defmodule HulaakiTest do
  use ExUnit.Case
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

  test "Packet protocol is implemented for Connect message" do
    message = %Message.Connect{}
    received = Packet.encode(message)
    expected = <<1::size(4), 0::size(1), 0::size(2), 0::size(1)>>

    assert expected == received
  end

  test "Packet protocol is implemented for ConnAck message" do
    message = %Message.ConnAck{}
    received = Packet.encode(message)
    expected = <<2::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for Publish message" do
    dup = 1
    qos = 1
    retain = 0
    message = %Message.Publish{id: 203, topic: 'test',
                               message: 'test', dup: dup,
                               qos: qos, retain: retain}
    received = Packet.encode(message)
    expected = <<3::size(4), dup::size(1), qos::size(2), retain::size(1)>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubAck message" do
    message = %Message.PubAck{}
    received = Packet.encode(message)
    expected = <<4::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubRec message" do
    message = %Message.PubRec{}
    received = Packet.encode(message)
    expected = <<5::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubRel message" do
    message = %Message.PubRel{}
    received = Packet.encode(message)
    expected = <<6::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubComp message" do
    message = %Message.PubComp{}
    received = Packet.encode(message)
    expected = <<7::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for Subscribe message" do
    message = %Message.Subscribe{}
    received = Packet.encode(message)
    expected = <<8::size(4), 0::size(1), 1::size(2), 0::size(1)>>

    assert expected == received
  end

  test "Packet protocol is implemented for SubAck message" do
    message = %Message.SubAck{}
    received = Packet.encode(message)
    expected = <<9::size(4), 0::size(1), 0::size(2), 0::size(1)>>

    assert expected == received
  end

  test "Packet protocol is implemented for Unsubscribe message" do
    message = %Message.Unsubscribe{}
    received = Packet.encode(message)
    expected = <<10::size(4), 0::size(1), 1::size(2), 0::size(1)>>

    assert expected == received
  end

  test "Packet protocol is implemented for UnsubAck message" do
    message = %Message.UnsubAck{}
    received = Packet.encode(message)
    expected = <<11::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "Packet protocol is implemented for PingReq message" do
    message = %Message.PingReq{}
    received = Packet.encode(message)
    expected = <<12::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "Packet protocol is implemented for PingResp message" do
    message = %Message.PingResp{}
    received = Packet.encode(message)
    expected = <<13::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "Packet protocol is implemented for Disconnect message" do
    message = %Message.Disconnect{}
    received = Packet.encode(message)
    expected = <<14::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end
end
