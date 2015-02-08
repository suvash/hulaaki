defmodule HulaakiTest do
  use ExUnit.Case
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

  test "Packet protocol is implemented for Connect message" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_flag = 0
    will_topic = "will-topic"
    will_message = "will-message"
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = %Message.Connect{client_id: id,
                                username: username,
                                password: password,
                                will_flag: will_flag,
                                will_topic: will_topic,
                                will_message: will_message,
                                will_qos: will_qos,
                                will_retain: will_retain,
                                clean_session: clean_session,
                                keep_alive: keep_alive}
    received = Packet.encode(message)
    expected = <<1::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<52>>

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
    message = %Message.Publish{id: 203, topic: "test",
                               message: "test", dup: dup,
                               qos: qos, retain: retain}
    received = Packet.encode(message)
    expected = <<3::size(4), dup::size(1), qos::size(2), retain::size(1)>> <> <<12>>

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
    id = :random.uniform(999999)
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1, 2]}
    received = Packet.encode(message)
    expected = <<8::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<17>>

    assert expected == received
  end

  test "Packet protocol is implemented for SubAck message" do
    id = :random.uniform(999999)
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    received = Packet.encode(message)
    expected = <<9::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<6>>

    assert expected == received
  end

  test "Packet protocol is implemented for Unsubscribe message" do
    id = :random.uniform(999999)
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    received = Packet.encode(message)
    expected = <<10::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<15>>

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
