defmodule Hulaaki.Decoder do
  alias Hulaaki.Message, as: Message
  use Bitwise

  def decode(<<packet_type_value::bits-4, _rest::bits>>) do
    case packet_type_value do
      <<12::size(4)>> -> decode_ping_request
      <<13::size(4)>> -> decode_ping_response
      <<14::size(4)>> -> decode_disconnect
    end
  end

  def decode_ping_request do
  def decode_remaining_length(<<0>>), do: 0

  def decode_remaining_length(bytes) do
    decode_remaining_length(bytes, 0, 1)
  end

  defp decode_remaining_length(<<encodedValue, rest::binary>>,
                               accumulator, multiplier)
  when (multiplier <= 2_097_152) do
    remaining_bytes? = fn(x) -> (Bitwise.band(x, 128) != 0) end

    decodedValue = Bitwise.band(encodedValue, 127) * multiplier

    if remaining_bytes?.(encodedValue) do
      decode_remaining_length(rest, accumulator + decodedValue, multiplier * 128)
    else
      accumulator + decodedValue
    end
  end
    Message.ping_request
  end

  def decode_ping_response do
    Message.ping_response
  end

  def decode_disconnect do
    Message.disconnect
  end
end
