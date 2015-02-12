defmodule Hulaaki.DecoderTest do
  use ExUnit.Case
  alias Hulaaki.Decoder, as: Decoder
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Packet, as: Packet

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
