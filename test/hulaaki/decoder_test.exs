defmodule Hulaaki.DecoderTest do
  use ExUnit.Case
  alias Hulaaki.Decoder, as: Decoder
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

  test "decode remaining length from provided bytes" do
    expected = 321
    received = Decoder.decode_remaining_length(<<193, 2>>)
    assert expected == received

    expected = 0
    received = Decoder.decode_remaining_length(<<0>>)
    assert expected == received

    expected = 127
    received = Decoder.decode_remaining_length(<<127>>)
    assert expected == received

    expected = 128
    received = Decoder.decode_remaining_length(<<128, 1>>)
    assert expected == received

    expected = 16_383
    received = Decoder.decode_remaining_length(<<255, 127>>)
    assert expected == received

    expected = 16_384
    received = Decoder.decode_remaining_length(<<128, 128, 1>>)
    assert expected == received

    expected = 2_097_151
    received = Decoder.decode_remaining_length(<<255, 255, 127>>)
    assert expected == received

    expected = 2_097_152
    received = Decoder.decode_remaining_length(<<128, 128, 128, 1>>)
    assert expected == received

    expected = 268_435_455
    received = Decoder.decode_remaining_length(<<255, 255, 255, 127>>)
    assert expected == received
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
