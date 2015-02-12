defmodule Hulaaki.Decoder do
  alias Hulaaki.Message, as: Message

  def decode(<<packet_type_value::bits-4, _rest::bits>>) do
    case packet_type_value do
      <<12::size(4)>> -> decode_ping_request
      <<13::size(4)>> -> decode_ping_response
      <<14::size(4)>> -> decode_disconnect
    end
  end

  def decode_ping_request do
    Message.ping_request
  end

  def decode_ping_response do
    Message.ping_response
  end

  def decode_disconnect do
    Message.disconnect
  end
end
