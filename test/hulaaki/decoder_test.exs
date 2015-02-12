defmodule Hulaaki.DecoderTest do
  use ExUnit.Case
  alias Hulaaki.Decoder, as: Decoder
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

  test "decode remaining length from provided bytes" do
    expected = {321, ""}
    received = Decoder.decode_remaining_length(<<193, 2>>)
    assert expected == received

    expected = {0, ""}
    received = Decoder.decode_remaining_length(<<0>>)
    assert expected == received

    expected = {127, ""}
    received = Decoder.decode_remaining_length(<<127>>)
    assert expected == received

    expected = {128, ""}
    received = Decoder.decode_remaining_length(<<128, 1>>)
    assert expected == received

    expected = {16_383, ""}
    received = Decoder.decode_remaining_length(<<255, 127>>)
    assert expected == received

    expected = {16_384, ""}
    received = Decoder.decode_remaining_length(<<128, 128, 1>>)
    assert expected == received

    expected = {2_097_151, ""}
    received = Decoder.decode_remaining_length(<<255, 255, 127>>)
    assert expected == received

    expected = {2_097_152, ""}
    received = Decoder.decode_remaining_length(<<128, 128, 128, 1>>)
    assert expected == received

    expected = {268_435_455, ""}
    received = Decoder.decode_remaining_length(<<255, 255, 255, 127>>)
    assert expected == received
  end

  test "attempts to decode a connection ack message" do
    session_present = 0
    return_code = 3
    message = Message.connect_ack(session_present, return_code)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a publish ack message" do
    id = :random.uniform(65_536)
    message = Message.publish_ack(id)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a publish receive message" do
    id = :random.uniform(65_536)
    message = Message.publish_receive(id)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a publish release message" do
    id = :random.uniform(65_536)
    message = Message.publish_release(id)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a publish complete message" do
    id = :random.uniform(65_536)
    message = Message.publish_complete(id)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a unsubscribe ack message" do
    id = :random.uniform(65_536)
    message = Message.unsubscribe_ack(id)
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a ping request message" do
    message = Message.ping_request
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a ping response message" do
    message = Message.ping_response
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

  test "attempts to decode a disconnect message" do
    message = Message.disconnect
    encoded_bytes = Packet.encode message

    decoded_message = Decoder.decode(encoded_bytes)
    assert decoded_message == message
  end

end
