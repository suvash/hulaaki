defmodule HulaakiTest do
  use ExUnit.Case
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

  test "Packet protocol encode is implemented for String" do
    binary = <<1,23,44,2,5>>
    assert binary == Packet.encode(binary)
  end

  test "Packet protocol encode is implemented for Connect message" do
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
    expected = <<16, 52, 0, 4, 77, 81, 84, 84, 4, 224>> <>
                 <<0, 10, 0, 14, 116, 101, 115, 116, 45, 99, 108, 105>> <>
                 <<101, 110, 116, 45, 105, 100>> <>
                 <<0, 9, 116, 101, 115, 116, 45, 117, 115, 101, 114>> <>
                 <<0, 13, 116, 101, 115, 116, 45, 112, 97, 115, 115>> <>
                 <<119, 111, 114, 100>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for Connect message" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_flag = 1
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
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded Connect bytes" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_flag = 1
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
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for ConnAck message" do
    session_present = 0
    return_code = 3
    message = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    received = Packet.encode(message)
    expected = <<32, 2, 0, 3>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for ConnAck message" do
    session_present = 0
    return_code = 3
    message = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded ConnAck bytes" do
    session_present = 0
    return_code = 3
    message = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for Publish message" do
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

  test "Packet protocol decode is implemented for Publish message" do
    dup = 1
    qos = 1
    retain = 0
    message = %Message.Publish{id: 203, topic: "test",
                               message: "test", dup: dup,
                               qos: qos, retain: retain}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded Publish bytes" do
    dup = 1
    qos = 1
    retain = 0
    message = %Message.Publish{id: 203, topic: "test",
                               message: "test", dup: dup,
                               qos: qos, retain: retain}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PubAck message" do
    id = 123
    message = %Message.PubAck{id: id}
    received = Packet.encode(message)
    expected = <<64, 2, 0, 123>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PubAck message" do
    id = 123
    message = %Message.PubAck{id: id}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded PubAck bytes" do
    id = 123
    message = %Message.PubAck{id: id}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PubRec message" do
    id = 34_231
    message = %Message.PubRec{id: id}
    received = Packet.encode(message)
    expected = <<80, 2, 133, 183>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PubRec message" do
    id = 34_231
    message = %Message.PubRec{id: id}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded PubRec bytes" do
    id = 34_231
    message = %Message.PubRec{id: id}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PubRel message" do
    id = 63_123
    message = %Message.PubRel{id: id}
    received = Packet.encode(message)
    expected = <<98, 2, 246, 147>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PubRel message" do
    id = 63_123
    message = %Message.PubRel{id: id}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded PubRel bytes" do
    id = 63_123
    message = %Message.PubRel{id: id}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PubComp message" do
    id = 3_124
    message = %Message.PubComp{id: id}
    received = Packet.encode(message)
    expected = <<112, 2, 12, 52>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PubComp message" do
    id = 3_124
    message = %Message.PubComp{id: id}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoeded PubComp bytes" do
    id = 3_124
    message = %Message.PubComp{id: id}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for Subscribe message" do
    id = 7_675
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1]}
    received = Packet.encode(message)
    expected = <<130, 17, 29, 251, 0, 5, 104, 101, 108, 108>> <>
                 <<111, 0, 0, 4, 99, 111, 111, 108, 1>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for Subscribe message" do
    id = 7_675
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1]}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded Subscribe bytes" do
    id = 7_675
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1]}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for SubAck message" do
    id = 43_218
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    received = Packet.encode(message)
    expected = <<144, 6, 168, 210, 0, 1, 2, 128>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for SubAck message" do
    id = 43_218
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded SubAck bytes" do
    id = 43_218
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for Unsubscribe message" do
    id = 19_234
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    received = Packet.encode(message)
    expected = <<162, 15, 75, 34, 0, 5, 104, 101, 108, 108>> <>
                 <<111, 0, 4, 99, 111, 111, 108>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for Unsubscribe message" do
    id = 19_234
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded Unsubscribe bytes" do
    id = 19_234
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for UnsubAck message" do
    id = 7_124
    message = %Message.UnsubAck{id: id}
    received = Packet.encode(message)
    expected = <<176, 2, 27, 212>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for UnsubAck message" do
    id = 7_124
    message = %Message.UnsubAck{id: id}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded UnsubAck bytes" do
    id = 7_124
    message = %Message.UnsubAck{id: id}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PingReq message" do
    message = %Message.PingReq{}
    received = Packet.encode(message)
    expected = <<12::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PingReq message" do
    message = %Message.PingReq{}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded PingReq bytes" do
    message = %Message.PingReq{}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for PingResp message" do
    message = %Message.PingResp{}
    received = Packet.encode(message)
    expected = <<13::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for PingResp message" do
    message = %Message.PingResp{}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded PingResp bytes" do
    message = %Message.PingResp{}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end

  test "Packet protocol encode is implemented for Disconnect message" do
    message = %Message.Disconnect{}
    received = Packet.encode(message)
    expected = <<14::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "Packet protocol decode is implemented for Disconnect message" do
    message = %Message.Disconnect{}
    assert message == Packet.decode(message)
  end

  test "Packet protocol decode is implemented for encoded Disconnect bytes" do
    message = %Message.Disconnect{}
    encoded_bytes = Packet.encode(message)

    decoded_message = Packet.decode(encoded_bytes)
    assert message == decoded_message
  end
end
