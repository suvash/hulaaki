defmodule Hulaaki.DecoderTest do
  use ExUnit.Case
  alias Hulaaki.Decoder
  alias Hulaaki.Message
  alias Hulaaki.Packet

  test "decode remaining length from provided bytes" do
    expected = {:error, {321, ""}}
    received = Decoder.decode_remaining_length(<<193, 2>>)
    assert expected == received

    expected = {:ok, {0, ""}}
    received = Decoder.decode_remaining_length(<<0>>)
    assert expected == received

    expected = {:error, {127, ""}}
    received = Decoder.decode_remaining_length(<<127>>)
    assert expected == received

    expected = {:error, {128, ""}}
    received = Decoder.decode_remaining_length(<<128, 1>>)
    assert expected == received

    expected = {:error, {16_383, ""}}
    received = Decoder.decode_remaining_length(<<255, 127>>)
    assert expected == received

    expected = {:error, {16_384, ""}}
    received = Decoder.decode_remaining_length(<<128, 128, 1>>)
    assert expected == received

    expected = {:error, {2_097_151, ""}}
    received = Decoder.decode_remaining_length(<<255, 255, 127>>)
    assert expected == received

    expected = {:error, {2_097_152, ""}}
    received = Decoder.decode_remaining_length(<<128, 128, 128, 1>>)
    assert expected == received

    expected = {:error, {268_435_455, ""}}
    received = Decoder.decode_remaining_length(<<255, 255, 255, 127>>)
    assert expected == received
  end

  test "attempts to decode a connect message" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_topic = "will-topic"
    will_message = "will-message"
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    message = Message.connect(id, username, password,
                              will_topic, will_message, will_qos,
                              will_retain, clean_session, keep_alive)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<32>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<32>>
  end

  test "attempts to decode a connection ack message" do
    session_present = 0
    return_code = 3
    message = Message.connect_ack(session_present, return_code)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<2, 0, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<2, 0, 0>>
  end

  test "attempts to decode a publish message" do
    id = :random.uniform(65_535)
    topic = "nice_topic"
    message = " a short message"
    dup = 0
    qos = 2
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<11, 2, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<11, 2, 0>>
  end

  test "attempts to decode a publish message when qos 0" do
    id = :random.uniform(65_535)
    topic = "nice_topic"
    message = " a short message"
    dup = 0
    qos = 0
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<11, 2, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<11, 2, 0>>
  end

  test "attempts to decode a publish ack message" do
    id = :random.uniform(65_535)
    message = Message.publish_ack(id)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<9, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<9, 0>>
  end

  test "attempts to decode a publish receive message" do
    id = :random.uniform(65_535)
    message = Message.publish_receive(id)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<9, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<9, 0>>
  end

  test "attempts to decode a publish release message" do
    id = :random.uniform(65_535)
    message = Message.publish_release(id)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<11, 5>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<11, 5>>
  end

  test "attempts to decode a publish complete message" do
    id = :random.uniform(65_535)
    message = Message.publish_complete(id)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<1, 8>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<1, 8>>
  end

  test "attempts to decode a subscribe message" do
    id = :random.uniform(65_535)
    topics = ["hello","cool"]
    qoses = [0, 1 ]
    message = Message.subscribe(id, topics, qoses)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<45, 11, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<45, 11, 0>>
  end

  test "attempts to decode a subscribe ack message" do
    id = :random.uniform(65_535)
    qoses = [0, 1, 2, 128]
    message = Message.subscribe_ack(id, qoses)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<8>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<8>>
  end

  test "attempts to decode a unsubscribe message" do
    id = :random.uniform(65_535)
    topics = ["hello","cool"]
    message = Message.unsubscribe(id, topics)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<13, 5, 0>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<13, 5, 0>>
  end

  test "attempts to decode a unsubscribe ack message" do
    id = :random.uniform(65_535)
    message = Message.unsubscribe_ack(id)

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<5, 9>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<5, 9>>
  end

  test "attempts to decode a ping request message" do
    message = Message.ping_request

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<99, 11>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<99, 11>>
  end

  test "attempts to decode a ping response message" do
    message = Message.ping_response

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<0, 1>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<0, 1>>
  end

  test "attempts to decode a disconnect message" do
    message = Message.disconnect

    encoded_bytes = Packet.encode message
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<>>

    encoded_bytes = Packet.encode(message) <> <<23, 43>>
    %{message: decoded_message, remainder: rest} = Decoder.decode(encoded_bytes)
    assert decoded_message == message
    assert rest == <<23, 43>>
  end

end
