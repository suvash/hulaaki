defmodule Hulaaki.Decoder do
  alias Hulaaki.Message, as: Message
  use Bitwise

  def decode(<<first_byte::bits-8, _rest::bits>> = bytes) do
    case first_byte do
      << 2::size(4), _::size(4)>> -> decode_connect_ack(bytes)
      << 3::size(4), _::size(4)>> -> decode_publish(bytes)
      << 4::size(4), _::size(4)>> -> decode_publish_ack(bytes)
      << 5::size(4), _::size(4)>> -> decode_publish_receive(bytes)
      << 6::size(4), 0::size(1), 1::size(2), 0::size(1)>> ->
                                     decode_publish_release(bytes)
      << 7::size(4), _::size(4)>> -> decode_publish_complete(bytes)
      << 8::size(4), 0::size(1), 1::size(2), 0::size(1)>> ->
                                     decode_subscribe(bytes)
      << 9::size(4), _::size(4)>> -> decode_subscribe_ack(bytes)
      <<10::size(4), 0::size(1), 1::size(2), 0::size(1)>> ->
                                     decode_unsubscribe(bytes)
      <<11::size(4), _::size(4)>> -> decode_unsubscribe_ack(bytes)
      <<12::size(4), _::size(4)>> -> decode_ping_request(bytes)
      <<13::size(4), _::size(4)>> -> decode_ping_response(bytes)
      <<14::size(4), _::size(4)>> -> decode_disconnect(bytes)
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

  defp decode_connect_ack(<<_, from_second_byte::binary>>) do
    {2, <<session_present, return_code>>} = decode_remaining_length(from_second_byte)
    Message.connect_ack(session_present, return_code)
  end

  defp decode_publish(<<3::size(4), dup::size(1),
                      qos::size(2), retain::size(1),
                      from_second_byte::binary>>) do
    {_, from_third_byte} = decode_remaining_length(from_second_byte)

    {topic, rest} = extract_topic(from_third_byte)
    <<id::size(16), message::binary>> = rest

    Message.publish(id, topic, message, dup, qos, retain)
  end

  defp decode_publish_ack(<<_, from_second_byte::binary>>) do
    {2, <<id::size(16)>>} = decode_remaining_length(from_second_byte)
    Message.publish_ack(id)
  end

  defp decode_publish_release(<<_, from_second_byte::binary>>) do
    {2, <<id::size(16)>>} = decode_remaining_length(from_second_byte)
    Message.publish_release(id)
  end

  defp decode_publish_receive(<<_, from_second_byte::binary>>) do
    {2, <<id::size(16)>>} = decode_remaining_length(from_second_byte)
    Message.publish_receive(id)
  end

  defp decode_publish_complete(<<_, from_second_byte::binary>>) do
    {2, <<id::size(16)>>} = decode_remaining_length(from_second_byte)
    Message.publish_complete(id)
  end

  defp decode_subscribe(<<_, from_second_byte::binary>>) do
    {_, rest} = decode_remaining_length(from_second_byte)

    <<id::size(16), payload::binary>> = rest
    {topics, qoses} = extract_topics_qoses(payload)

    Message.subscribe(id, topics, qoses)
  end

  defp extract_topics_qoses(binary) do
    extract_topics_qoses(binary, {[], []})
  end

  defp extract_topics_qoses(<<>>, {acc_topics, acc_qoses}) do
    {Enum.reverse(acc_topics), Enum.reverse(acc_qoses)}
  end

  defp extract_topics_qoses(binary, {acc_topics, acc_qoses}) do
    cond do
      length(acc_topics) == length(acc_qoses) ->
        {element, rest} = extract_topic(binary)
        extract_topics_qoses(rest, {[element | acc_topics], acc_qoses})
      length(acc_topics) > length(acc_qoses) ->
        {element, rest} = extract_qos(binary)
        extract_topics_qoses(rest, {acc_topics, [element | acc_qoses]})
    end
  end

  defp decode_subscribe_ack(<<_, from_second_byte::binary>>) do
    {_, rest} = decode_remaining_length(from_second_byte)

    <<id::size(16), payload::binary>> = rest
    qoses = extract_qos_list(payload)

    Message.subscribe_ack(id, qoses)
  end

  defp extract_qos_list(binary) do
    extract_qos_list(binary, [])
  end

  defp extract_qos_list(<<>>, accumulator), do: Enum.reverse(accumulator)

  defp extract_qos_list(binary, accumulator) do
    {element, rest} = extract_qos(binary)
    extract_qos_list(rest, [element | accumulator ])
  end

  defp extract_qos(<<qos::size(8), rest::binary>>) do
    {qos, rest}
  end

  defp decode_unsubscribe(<<_, from_second_byte::binary>>) do
    {_, rest} = decode_remaining_length(from_second_byte)

    <<id::size(16), payload::binary>> = rest
    topics = extract_topic_list(payload)

    Message.unsubscribe(id, topics)
  end

  defp extract_topic_list(binary) do
    extract_topic_list(binary, [])
  end

  defp extract_topic_list(<<>>, accumulator), do: Enum.reverse(accumulator)

  defp extract_topic_list(binary, accumulator) do
    {element, rest} = extract_topic(binary)
    extract_topic_list(rest, [element | accumulator ])
  end

  def extract_topic(<<len::size(16), topic::bytes-size(len), rest::binary>>) do
    {topic, rest}
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
