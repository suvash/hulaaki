defmodule Hulaaki.Decoder do
  alias Hulaaki.Message
  use Bitwise
  @moduledoc """
  Provides functions for decoding bytes(binary) to Message structs
  """

  @doc """
  Decodes a binary to a tuple containing Message struct and a remainder
  """
  def decode(<<first_byte::bits-8, _rest::bits>> = bytes) do
    case first_byte do
      << 1::size(4), _::size(4)>> -> decode_connect(bytes)
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

  @doc """
  Decodes remaining length from bytes encoded using a variable length
  encoding scheme specified in MQTT 3.1.1 spec section 2.2.3
  """
  def decode_remaining_length(<<0>>), do: {:ok, {0, ""}}

  def decode_remaining_length(bytes) do
    decode_remaining_length(bytes, 0, 1)
  end

  defp decode_remaining_length(<<encodedValue, rest::binary>>,
                               accumulator, multiplier)
    when (multiplier <= 2_097_152) do
      remaining_bytes? = fn(x) -> (Bitwise.band(x, 128) != 0) end

      decodedValue = Bitwise.band(encodedValue, 127) * multiplier
      length = accumulator + decodedValue

      if remaining_bytes?.(encodedValue) do
        if byte_size(rest) > 0 do 
          decode_remaining_length(rest, length, multiplier * 128)
        else
          {:error, {length, ""}}
        end          
      else
        if byte_size(rest) >= length do 
          {:ok, {length, rest}}
        else
          {:error, {length, rest}}
        end
      end
  end

  defp decode_connect(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {length, from_third_byte}} ->
        <<message_bytes::bytes-size(length), remainder::binary>> = from_third_byte

        <<4::size(16)>> <> "MQTT" <> <<4::size(8)>> <>
          <<username_flag::size(1), password_flag::size(1),
            will_retain::size(1), will_qos::size(2),
            will_flag::size(1), clean_session::size(1), 0::size(1)>> <>
          <<keep_alive::size(16)>> <>
          <<rest::binary>> = message_bytes

        extract_if = fn(exp, str) -> if exp do extract_string(str) else {"", str} end end
        extract_if_flag = fn(num, str) -> extract_if.(num == 1, str) end

        {client_id,    rest_1} = extract_if.(true, rest)
        {will_topic,   rest_2} = extract_if_flag.(will_flag, rest_1)
        {will_message, rest_3} = extract_if_flag.(will_flag, rest_2)
        {username,     rest_4} = extract_if_flag.(username_flag, rest_3)
        {password,     <<>>}   = extract_if_flag.(password_flag, rest_4)

        message = Message.connect(client_id, username, password,
                                  will_topic, will_message, will_qos,
                                  will_retain, clean_session, keep_alive)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_connect_ack(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
        <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

        <<session_present, return_code>> = message_bytes

        message = Message.connect_ack(session_present, return_code)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_publish(<<3::size(4), dup::size(1),
                      qos::size(2), retain::size(1),
                      from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {length, from_third_byte}} ->
        <<message_bytes::bytes-size(length), remainder::binary>> = from_third_byte

        {topic, rest} = extract_topic(message_bytes)
        {id, message} =
          case qos do
            0 ->
              {nil, rest}
            _ ->
              <<id2::size(16), message2::binary>> = rest
              {id2, message2}
          end


        message =
          case qos do
            0 -> Message.publish(topic, message, dup, qos, retain)
            _ -> Message.publish(id, topic, message, dup, qos, retain)
          end
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_publish_ack(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
        <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

        <<id::size(16)>> = message_bytes

        message = Message.publish_ack(id)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_publish_release(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
        <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

        <<id::size(16)>> = message_bytes

        message = Message.publish_release(id)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_publish_receive(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
        <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

        <<id::size(16)>> = message_bytes

        message = Message.publish_receive(id)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_publish_complete(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
      <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

      <<id::size(16)>> = message_bytes

      message = Message.publish_complete(id)
      %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_subscribe(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {length, from_third_byte}} ->
      <<message_bytes::bytes-size(length), remainder::binary>> = from_third_byte

      <<id::size(16), payload::binary>> = message_bytes
      {topics, qoses} = extract_topics_qoses(payload)

      message = Message.subscribe(id, topics, qoses)
      %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
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

  defp decode_subscribe_ack(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {length, from_third_byte}} ->
        <<message_bytes::bytes-size(length), remainder::binary>> = from_third_byte

        <<id::size(16), payload::binary>> = message_bytes
        qoses = extract_qos_list(payload)

        message = Message.subscribe_ack(id, qoses)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
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

  defp decode_unsubscribe(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {length, from_third_byte}} ->
        <<message_bytes::bytes-size(length), remainder::binary>> = from_third_byte

        <<id::size(16), payload::binary>> = message_bytes
        topics = extract_topic_list(payload)

        message = Message.unsubscribe(id, topics)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp extract_topic_list(binary), do: extract_topic_list(binary, [])

  defp extract_topic_list(<<>>, accumulator), do: Enum.reverse(accumulator)

  defp extract_topic_list(binary, accumulator) do
    {element, rest} = extract_topic(binary)
    extract_topic_list(rest, [element | accumulator ])
  end

  defp extract_topic(binary) do
    extract_string(binary)
  end

  defp extract_string(<<len::size(16), topic::bytes-size(len), rest::binary>>) do
    {topic, rest}
  end

  defp decode_unsubscribe_ack(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {2, from_third_byte}} ->
        <<message_bytes::bytes-size(2), remainder::binary>> = from_third_byte

        <<id::size(16)>> = message_bytes

        message = Message.unsubscribe_ack(id)
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_ping_request(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {0, from_third_byte}} ->
        <<_::bytes-size(0), remainder::binary>> = from_third_byte

        message = Message.ping_request
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_ping_response(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {0, from_third_byte}} ->
        <<_::bytes-size(0), remainder::binary>> = from_third_byte

        message = Message.ping_response
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end

  defp decode_disconnect(<<_, from_second_byte::binary>> = payload_bytes) do
    case decode_remaining_length(from_second_byte) do 
      {:ok, {0, from_third_byte}} ->
        <<_::bytes-size(0), remainder::binary>> = from_third_byte

        message = Message.disconnect
        %{message: message, remainder: remainder}

      {:error, _} ->
        %{message: nil, remainder: payload_bytes}
    end
  end
end
