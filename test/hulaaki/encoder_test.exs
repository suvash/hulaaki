defmodule Hulaaki.EncoderTest do
  use ExUnit.Case
  alias Hulaaki.Encoder
  alias Hulaaki.Message

  defmodule Nonsense do
    defstruct type: :NONSENSE
  end

  test "raises error for encoding unmatched struct" do
    assert_raise FunctionClauseError, fn ->
      message = %Nonsense{}
      Encoder.encode_fixed_header(message)
    end
  end

  test "encodes fixed header for Connect struct" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_topic = ""
    will_message = ""
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = %Message.Connect{client_id: id,
                                username: username,
                                password: password,
                                will_topic: will_topic,
                                will_message: will_message,
                                will_qos: will_qos,
                                will_retain: will_retain,
                                clean_session: clean_session,
                                keep_alive: keep_alive}
    received = Encoder.encode_fixed_header(message)
    expected = <<1::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<52>>

    assert expected == received
  end

  test "encodes fixed header for ConnAck struct" do
    message = %Message.ConnAck{}
    received = Encoder.encode_fixed_header(message)
    expected = <<2::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for Publish struct" do
    dup = 0
    qos = 2
    retain = 1
    message = %Message.Publish{id: 203, topic: "test",
                               message: "test", dup: dup,
                               qos: qos, retain: retain}
    received = Encoder.encode_fixed_header(message)
    expected = <<3::size(4), dup::size(1), qos::size(2), retain::size(1)>> <> <<12>>

    assert expected == received
  end

  test "encodes fixed header for PubAck struct" do
    message = %Message.PubAck{}
    received = Encoder.encode_fixed_header(message)
    expected = <<4::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubRec struct" do
    message = %Message.PubRec{}
    received = Encoder.encode_fixed_header(message)
    expected = <<5::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubRel struct" do
    message = %Message.PubRel{}
    received = Encoder.encode_fixed_header(message)
    expected = <<6::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubComp struct" do
    message = %Message.PubComp{}
    received = Encoder.encode_fixed_header(message)
    expected = <<7::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for Subscribe struct" do
    id = :random.uniform(65_536)
    message = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1, 2]}
    received = Encoder.encode_fixed_header(message)
    expected = <<8::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<17>>

    assert expected == received
  end

  test "encodes fixed header for SubAck struct" do
    id = :random.uniform(65_536)
    message = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    received = Encoder.encode_fixed_header(message)
    expected = <<9::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<6>>

    assert expected == received
  end

  test "encodes fixed header for Unsubscribe struct" do
    id = :random.uniform(65_536)
    message = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    received = Encoder.encode_fixed_header(message)
    expected = <<10::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<15>>

    assert expected == received
  end

  test "encodes fixed header for UnsubAck struct" do
    message = %Message.UnsubAck{}
    received = Encoder.encode_fixed_header(message)
    expected = <<11::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PingReq struct" do
    message = %Message.PingReq{}
    received = Encoder.encode_fixed_header(message)
    expected = <<12::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "encodes fixed header for PingResp struct" do
    message = %Message.PingResp{}
    received = Encoder.encode_fixed_header(message)
    expected = <<13::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "encodes fixed header for Disconnect struct" do
    message = %Message.Disconnect{}
    received = Encoder.encode_fixed_header(message)
    expected = <<14::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "calculate remaining length for Connect struct" do
    client_id = "awesome=client-id"
    username = "test-user"
    password = "test-password"
    will_topic = "will-topic"
    will_message = "will-message"
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = %Message.Connect{client_id: client_id,
                               username: username,
                               password: password,
                               will_topic: will_topic,
                               will_message: will_message,
                               will_qos: will_qos,
                               will_retain: will_retain,
                               clean_session: clean_session,
                               keep_alive: keep_alive}
    received = Encoder.calculate_remaining_length(message)
    expected = 81

    assert expected == received

    encoded_length = byte_size(Encoder.encode_variable_header(message) <>
                                 Encoder.encode_payload(message))

    assert encoded_length == received
  end

  test "calculate remaining length for Publish struct" do
    id = :random.uniform(65_536)
    topic = "nice topic"
    publish_message = "a short message"
    message = Message.publish(id, topic, publish_message, 0, 2, 1)
    received = Encoder.calculate_remaining_length(message)
    expected = 29

    assert expected == received
    encoded_length = byte_size(Encoder.encode_variable_header(message) <>
                                 Encoder.encode_payload(message))

    assert encoded_length == received
  end

  test "calculate remaining length for Subscribe struct" do
    id = :random.uniform(65_536)
    topics = ["hello","cool"]
    qoses = [0, 2]
    message = Message.subscribe(id, topics, qoses)
    received = Encoder.calculate_remaining_length(message)
    expected = 17

    assert expected == received
    encoded_length = byte_size(Encoder.encode_variable_header(message) <>
                                 Encoder.encode_payload(message))

    assert encoded_length == received
  end

  test "calculate remaining length for SubAck struct" do
    id = :random.uniform(65_536)
    qoses = [0, 1, 2, 128]
    message = Message.subscribe_ack(id, qoses)
    received = Encoder.calculate_remaining_length(message)
    expected = 6

    assert expected == received
    encoded_length = byte_size(Encoder.encode_variable_header(message) <>
                                 Encoder.encode_payload(message))

    assert encoded_length == received
  end

  test "calculate remaining length for Unsubscribe struct" do
    message = Message.unsubscribe(123, ["hello", "there"])
    received = Encoder.calculate_remaining_length(message)
    expected = 16

    assert expected == received
    encoded_length = byte_size(Encoder.encode_variable_header(message) <>
                                 Encoder.encode_payload(message))

    assert encoded_length == received
  end

  test "encode fixed header remaining length number to bytes" do
    received = Encoder.encode_fixed_header_remaining_length(321)
    expected = <<193, 2>>
    assert expected == received

    assert_raise FunctionClauseError, fn ->
      Encoder.encode_fixed_header_remaining_length(-321)
    end

    received = Encoder.encode_fixed_header_remaining_length(0)
    expected = <<0>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(127)
    expected = <<127>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(128)
    expected = <<128, 1>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(16_383)
    expected = <<255, 127>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(16_384)
    expected = <<128, 128, 1>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(2_097_151)
    expected = <<255, 255, 127>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(2_097_152)
    expected = <<128, 128, 128, 1>>
    assert expected == received

    received = Encoder.encode_fixed_header_remaining_length(268_435_455)
    expected = <<255, 255, 255, 127>>
    assert expected == received
  end

  test "encodes variable header for Connect struct" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_topic = ""
    will_message = ""
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = %Message.Connect{client_id: id,
                                username: username,
                                password: password,
                                will_topic: will_topic,
                                will_message: will_message,
                                will_qos: will_qos,
                                will_retain: will_retain,
                                clean_session: clean_session,
                                keep_alive: keep_alive}
    received = Encoder.encode_variable_header(message)
    username_flag = 1
    password_flag = 1
    will_flag = 0
    expected = <<4::size(16)>> <> "MQTT" <> <<4::size(8)>> <>
                 <<username_flag::size(1), password_flag::size(1),
                   will_retain::size(1), will_qos::size(2),
                   will_flag::size(1), clean_session::size(1), 0::size(1)>> <>
                 <<keep_alive::size(16)>>

    assert expected == received
  end

  test "encodes variable header for ConnAck struct" do
    session_present = 0
    return_code = 3
    message = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    received = Encoder.encode_variable_header(message)
    expected = <<0, 3>>

    assert expected == received
  end

  test "encodes variable header for Publish struct" do
    id = :random.uniform(65_536)
    topic = "topic"
    message = "message"
    dup = 0
    qos = 2
    retain = 1
    message = %Message.Publish{id: id, topic: topic,
                                message: message, dup: dup,
                                qos: qos, retain: retain}
    received = Encoder.encode_variable_header(message)
    expected = <<byte_size(topic)::size(16)>> <> topic <> <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for PubAck struct" do
    id = :random.uniform(65_536)
    message = %Message.PubAck{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for PubRec struct" do
    id = :random.uniform(65_536)
    message = %Message.PubRec{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for PubRel struct" do
    id = :random.uniform(65_536)
    message = %Message.PubRel{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for PubComp struct" do
    id = :random.uniform(65_536)
    message = %Message.PubComp{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for Subscribe struct" do
    id = :random.uniform(65_536)
    message = %Message.Subscribe{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for SubAck struct" do
    id = :random.uniform(65_536)
    message = %Message.SubAck{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for Unsubscribe struct" do
    id = :random.uniform(65_536)
    message = %Message.Unsubscribe{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes variable header for UnsubAck struct" do
    id = :random.uniform(65_536)
    message = %Message.UnsubAck{id: id}
    received = Encoder.encode_variable_header(message)
    expected = <<id::size(16)>>

    assert expected == received
  end

  test "encodes payload for Connect struct" do
    id = "client"
    username = "user"
    password = "pass"
    will_topic = "topic"
    will_message = "message"
    message = %Message.Connect{client_id: id,
                                username: username,
                                password: password,
                                will_message: will_message,
                                will_topic: will_topic}
    received = Encoder.encode_payload(message)
    expected = <<0, 6, 99, 108, 105, 101, 110, 116>> <>
                 <<0, 5, 116, 111, 112, 105, 99>> <>
                 <<0, 7, 109, 101, 115, 115, 97, 103, 101>> <>
                 <<0, 4, 117, 115, 101, 114>> <>
                 <<0, 4, 112, 97, 115, 115>>

    assert expected == received
  end

  test "encodes payload for Publish struct" do
    message = %Message.Publish{message: "this is awesome"}
    received = Encoder.encode_payload(message)
    expected = <<116, 104, 105, 115>> <> <<32>> <>
                 <<105, 115>> <> <<32>> <>
                 <<97, 119, 101, 115, 111, 109, 101>>

    assert expected == received
  end

  test "encodes payload for Subscribe struct" do
    message = %Message.Subscribe{topics: ["hello", "really"],
                                 requested_qoses: [1, 2]}
    received = Encoder.encode_payload(message)
    expected = <<0, 5, 104, 101, 108, 108, 111, 1>> <>
                 <<0, 6, 114, 101, 97, 108, 108, 121, 2>>

    assert expected == received
  end

  test "encodes payload for SubAck struct" do
    message = %Message.SubAck{granted_qoses: [0, 1, 2, 128]}
    received = Encoder.encode_payload(message)
    expected = <<0, 1, 2, 128>>

    assert expected == received
  end

  test "encodes payload for Unsubscribe struct" do
    topics = [ "nice", "really"]
    message = %Message.Unsubscribe{topics: topics}
    received = Encoder.encode_payload(message)
    expected = <<0, 4, 110, 105, 99, 101, 0, 6, 114, 101, 97, 108, 108, 121>>

    assert expected == received
  end
end
