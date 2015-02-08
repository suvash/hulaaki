defmodule Hulaaki.Control.CodecTest do
  use ExUnit.Case
  alias Hulaaki.Control.Codec, as: Codec
  alias Hulaaki.Control.Message, as: Message

  defmodule Nonsense do
    defstruct type: :NONSENSE
  end

  test "raises error for encoding unmatched struct" do
    assert_raise FunctionClauseError, fn ->
      message = %Nonsense{}
      Codec.encode_fixed_header(message)
    end
  end

  test "encodes fixed header for Connect struct" do
    message = %Message.Connect{}
    received = Codec.encode_fixed_header(message)
    expected = <<1::size(4), 0::size(1), 0::size(2), 0::size(1)>>

    assert expected == received
  end

  test "encodes fixed header for ConnAck struct" do
    message = %Message.ConnAck{}
    received = Codec.encode_fixed_header(message)
    expected = <<2::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for Publish struct" do
    dup = 0
    qos = 2
    retain = 1
    message = %Message.Publish{id: 203, topic: 'test',
                               message: 'test', dup: dup,
                               qos: qos, retain: retain}
    received = Codec.encode_fixed_header(message)
    expected = <<3::size(4), dup::size(1), qos::size(2), retain::size(1)>>

    assert expected == received
  end

  test "encodes fixed header for PubAck struct" do
    message = %Message.PubAck{}
    received = Codec.encode_fixed_header(message)
    expected = <<4::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubRec struct" do
    message = %Message.PubRec{}
    received = Codec.encode_fixed_header(message)
    expected = <<5::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubRel struct" do
    message = %Message.PubRel{}
    received = Codec.encode_fixed_header(message)
    expected = <<6::size(4), 0::size(1), 1::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PubComp struct" do
    message = %Message.PubComp{}
    received = Codec.encode_fixed_header(message)
    expected = <<7::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for Subscribe struct" do
    message = %Message.Subscribe{}
    received = Codec.encode_fixed_header(message)
    expected = <<8::size(4), 0::size(1), 1::size(2), 0::size(1)>>

    assert expected == received
  end

  test "encodes fixed header for SubAck struct" do
    message = %Message.SubAck{}
    received = Codec.encode_fixed_header(message)
    expected = <<9::size(4), 0::size(1), 0::size(2), 0::size(1)>>

    assert expected == received
  end

  test "encodes fixed header for Unsubscribe struct" do
    message = %Message.Unsubscribe{}
    received = Codec.encode_fixed_header(message)
    expected = <<10::size(4), 0::size(1), 1::size(2), 0::size(1)>>

    assert expected == received
  end

  test "encodes fixed header for UnsubAck struct" do
    message = %Message.UnsubAck{}
    received = Codec.encode_fixed_header(message)
    expected = <<11::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<2>>

    assert expected == received
  end

  test "encodes fixed header for PingReq struct" do
    message = %Message.PingReq{}
    received = Codec.encode_fixed_header(message)
    expected = <<12::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "encodes fixed header for PingResp struct" do
    message = %Message.PingResp{}
    received = Codec.encode_fixed_header(message)
    expected = <<13::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "encodes fixed header for Disconnect struct" do
    message = %Message.Disconnect{}
    received = Codec.encode_fixed_header(message)
    expected = <<14::size(4), 0::size(1), 0::size(2), 0::size(1)>> <> <<0>>

    assert expected == received
  end

  test "calculate remaining length for Connect struct" do
    client_id = "awesome=client-id"
    username = "test-user"
    password = "test-password"
    will_flag = 1
    will_topic = "will-topic"
    will_message = "will-message"
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = %Message.Connect{client_id: client_id,
                               username: username,
                               password: password,
                               will_flag: will_flag,
                               will_topic: will_topic,
                               will_message: will_message,
                               will_qos: will_qos,
                               will_retain: will_retain,
                               clean_session: clean_session,
                               keep_alive: keep_alive}
    received = Codec.calculate_remaining_length(message)
    expected = 52

    assert expected == received
  end

  test "calculate remaining length for Publish struct" do
    id = :random.uniform(999999)
    topic = "nice topic"
    publish_message = "a short message"
    message = Message.publish(id, topic, publish_message, 0, 2, 1)
    received = Codec.calculate_remaining_length(message)
    expected = 29

    assert expected == received
  end

  test "calculate remaining length for Subscribe struct" do
    id = :random.uniform(999999)
    topics = ["hello","cool"]
    qoses = [0, 2, 1, 128]
    message = Message.subscribe(id, topics, qoses)
    received = Codec.calculate_remaining_length(message)
    expected = 17

    assert expected == received
  end

  test "calculate remaining length for SubAck struct" do
    id = :random.uniform(999999)
    qoses = [0, 1, 2, 128]
    message = Message.subscribe_ack(id, qoses)
    received = Codec.calculate_remaining_length(message)
    expected = 6

    assert expected == received
  end

  test "calculate remaining length for Unsubscribe struct" do
    message = Message.unsubscribe(123, ["hello", "there"])
    received = Codec.calculate_remaining_length(message)
    expected = 16

    assert expected == received
  end

  test "encode fixed header remaining length number to bytes" do
    received = Codec.encode_fixed_header_remaining_length(321)
    expected = <<193, 2>>
    assert expected == received

    assert_raise FunctionClauseError, fn ->
      Codec.encode_fixed_header_remaining_length(-321)
    end

    received = Codec.encode_fixed_header_remaining_length(0)
    expected = <<0>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(127)
    expected = <<127>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(128)
    expected = <<128, 1>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(16_383)
    expected = <<255, 127>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(16_384)
    expected = <<128, 128, 1>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(2_097_151)
    expected = <<255, 255, 127>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(2_097_152)
    expected = <<128, 128, 128, 1>>
    assert expected == received

    received = Codec.encode_fixed_header_remaining_length(268_435_455)
    expected = <<255, 255, 255, 127>>
    assert expected == received
  end

end
