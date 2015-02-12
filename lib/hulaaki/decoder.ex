defmodule Hulaaki.Decoder do
  alias Hulaaki.Message, as: Message
  use Bitwise

  def decode(<<packet_type_value::bits-4, _rest::bits>> = bytes) do
    case packet_type_value do
      <<11::size(4)>> -> decode_unsubscribe_ack(bytes)
      <<12::size(4)>> -> decode_ping_request(bytes)
      <<13::size(4)>> -> decode_ping_response(bytes)
      <<14::size(4)>> -> decode_disconnect(bytes)
    end
  end

  def decode_remaining_length(<<0>>), do: {0, ""}

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
        {accumulator + decodedValue, rest}
      end
  end

  defp decode_unsubscribe_ack(<<_, from_second_byte::binary>>) do
    {2, <<id::size(16)>>} = decode_remaining_length(from_second_byte)
    Message.unsubscribe_ack(id)
  end

  defp decode_ping_request(<<_, from_second_byte::binary>>) do
    {0, ""} = decode_remaining_length(from_second_byte)
    Message.ping_request
  end

  defp decode_ping_response(<<_, from_second_byte::binary>>) do
    {0, ""} = decode_remaining_length(from_second_byte)
    Message.ping_response
  end

  defp decode_disconnect(<<_, from_second_byte::binary>>) do
    {0, ""}= decode_remaining_length(from_second_byte)
    Message.disconnect
  end
end
