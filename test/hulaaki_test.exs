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
    expected = <<16, 48, 0, 4, 77, 81, 84, 84, 4, 224, 0>> <>
                 <<10, 116, 101, 115, 116, 45, 99, 108, 105>> <>
                 <<101, 110, 116, 45, 105, 100, 116, 101, 115>> <>
                 <<116, 45, 117, 115, 101, 114, 0, 13, 116, 101>> <>
                 <<115, 116, 45, 112, 97, 115, 115, 119, 111, 114, 100>>

    assert expected == received
  end

  test "Packet protocol is implemented for ConnAck message" do
    session_present = 0
    return_code = 3
    message = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    received = Packet.encode(message)
    expected = <<32, 2, 0, 3>>

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
    expected = <<58, 12, 0, 4, 116, 101, 115, 116, 0, 203>> <>
                 <<116, 101, 115, 116>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubAck message" do
    id = 247939
    message = %Message.PubAck{id: id}
    received = Packet.encode(message)
    expected = <<64, 2, 200, 131>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubRec message" do
    id = 443585
    message = %Message.PubRec{id: id}
    received = Packet.encode(message)
    expected = <<80, 2, 196, 193>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubRel message" do
    id = 428318
    message = %Message.PubRel{id: id}
    received = Packet.encode(message)
    expected = <<98, 2, 137, 30>>

    assert expected == received
  end

  test "Packet protocol is implemented for PubComp message" do
    id = 184628
    message = %Message.PubComp{id: id}
    received = Packet.encode(message)
    expected = <<112, 2, 209, 52>>

    assert expected == received
  end

  test "Packet protocol is implemented for Subscribe message" do
    id = 342568
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1, 2]}
    received = Packet.encode(message)
    expected = <<130, 17, 58, 40, 0, 5, 104, 101, 108, 108>> <>
                 <<111, 0, 0, 4, 99, 111, 111, 108, 1>>

    assert expected == received
  end

  test "Packet protocol is implemented for SubAck message" do
    id = 672341
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    received = Packet.encode(message)
    expected = <<144, 6, 66, 85, 0, 1, 2, 128>>

    assert expected == received
  end

  test "Packet protocol is implemented for Unsubscribe message" do
    id = 972824
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    received = Packet.encode(message)
    expected = <<162, 15, 216, 24, 0, 5, 104, 101, 108, 108>> <>
                 <<111, 0, 4, 99, 111, 111, 108>>

    assert expected == received
  end

  test "Packet protocol is implemented for UnsubAck message" do
    id = :random.uniform(999999)
    message = %Message.UnsubAck{id: id}
    received = Packet.encode(message)
    expected = <<176, 2, 196, 193>>

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
