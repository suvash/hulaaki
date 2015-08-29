defmodule Hulaaki.Encoder do
  alias Hulaaki.Message
  require Bitwise
  @moduledoc """
  Provides functions for encoding Message structs to bytes(binary)
  """

  @type dup :: 0|1
  @type qos :: 0|1|2
  @type retain :: 0|1
  @type packet_value :: 1|2|3|4|5|6|7|8|9|10|11|12|13|14

  @doc """
  Encodes the fixed header (as specified in MQTT spec) for a given Message struct
  """
  def encode_fixed_header(%Message.Connect{} = message) do
    remaining_length = calculate_remaining_length(message)
    encode_fixed_header_first_byte(1, 0, 0, 0) <>
      encode_fixed_header_second_byte(remaining_length)
  end

  def encode_fixed_header(%Message.ConnAck{}) do
    encode_fixed_header_first_byte(2, 0, 0, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.Publish{dup: dup, qos: qos,
                                           retain: retain} = message) do
    remaining_length = calculate_remaining_length(message)
    encode_fixed_header_first_byte(3, dup, qos, retain) <>
      encode_fixed_header_second_byte(remaining_length)
  end

  def encode_fixed_header(%Message.PubAck{}) do
    encode_fixed_header_first_byte(4, 0, 0, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.PubRec{}) do
    encode_fixed_header_first_byte(5, 0, 0, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.PubRel{}) do
    encode_fixed_header_first_byte(6, 0, 1, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.PubComp{}) do
    encode_fixed_header_first_byte(7, 0, 0, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.Subscribe{} = message) do
    remaining_length = calculate_remaining_length(message)
    encode_fixed_header_first_byte(8, 0, 1, 0) <>
      encode_fixed_header_second_byte(remaining_length)
  end

  def encode_fixed_header(%Message.SubAck{} = message) do
    remaining_length = calculate_remaining_length(message)
    encode_fixed_header_first_byte(9, 0, 0, 0) <>
      encode_fixed_header_second_byte(remaining_length)
  end

  def encode_fixed_header(%Message.Unsubscribe{} = message) do
    remaining_length = calculate_remaining_length(message)
    encode_fixed_header_first_byte(10, 0, 1, 0) <>
      encode_fixed_header_second_byte(remaining_length)
  end

  def encode_fixed_header(%Message.UnsubAck{}) do
    encode_fixed_header_first_byte(11, 0, 0, 0) <>
      encode_fixed_header_second_byte(2)
  end

  def encode_fixed_header(%Message.PingReq{}) do
    encode_fixed_header_first_byte(12, 0, 0, 0) <>
      encode_fixed_header_second_byte(0)
  end

  def encode_fixed_header(%Message.PingResp{}) do
    encode_fixed_header_first_byte(13, 0, 0, 0) <>
      encode_fixed_header_second_byte(0)
  end

  def encode_fixed_header(%Message.Disconnect{}) do
    encode_fixed_header_first_byte(14, 0, 0, 0) <>
      encode_fixed_header_second_byte(0)
  end

  @doc """
  Calculates the remaining length (as specified in MQTT spec) for a given Message struct
  """
  def calculate_remaining_length(%Message.Connect{client_id: client_id,
                                                  username: username,
                                                  password: password,
                                                  will_topic: will_topic,
                                                  will_message: will_message}) do
    prefix_length = fn(str) -> byte_size(str) + 2 end
    prefix_length_if = fn(exp, str) ->
      if exp do
        prefix_length.(str)
      else
        0
      end
    end

    variable_header_length = 10
    client_id_length = prefix_length.(client_id)
    will_topic_length = prefix_length_if.(will_topic != "", will_topic)
    will_message_length = prefix_length_if.(will_message != "", will_message)
    username_length  = prefix_length_if.(username != "", username)
    password_length  = prefix_length_if.(password != "", password)

    variable_header_length + client_id_length \
      + will_topic_length + will_message_length \
      + username_length + password_length
  end

  def calculate_remaining_length(%Message.Publish{topic: topic, message: message, qos: qos}) do
    # no message id when qos = 0
    message_id_length = (qos == 0) && 0 || 2
    topic_length_byte_length = 2
    message_length = byte_size(message)
    topic_length = byte_size(topic)

    message_id_length + topic_length_byte_length + message_length + topic_length
  end

  def calculate_remaining_length(%Message.Subscribe{topics: topics}) do
    message_id_length = 2
    topic_length_byte_length = 2
    qos_length = 1
    topic_qos_length = fn(t) -> (byte_size(t) +
                                 topic_length_byte_length + qos_length) end
    topics_qoses_length = topics |> Enum.map(topic_qos_length) |> Enum.sum

    message_id_length + topics_qoses_length
  end

  def calculate_remaining_length(%Message.SubAck{granted_qoses: granted_qoses}) do
    message_id_length = 2
    granted_qoses_length = length(granted_qoses)

    message_id_length + granted_qoses_length
  end

  def calculate_remaining_length(%Message.Unsubscribe{topics: topics}) do
    message_id_length = 2
    topic_length_byte_length = 2
    topic_length = fn(t) -> (byte_size(t) + topic_length_byte_length) end
    topics_length = topics |> Enum.map(topic_length) |> Enum.sum

    message_id_length + topics_length
  end

  @spec encode_fixed_header_first_byte(packet_value, dup, qos, retain) :: binary
  defp encode_fixed_header_first_byte(packet_value, dup, qos, retain)
    when (packet_value > 0 and packet_value < 15 )
    and (dup == 0 or dup == 1)
    and (qos == 0 or qos == 1 or qos == 2)
    and (retain == 0 or retain == 1) do

      <<packet_value::size(4), dup::size(1), qos::size(2), retain::size(1)>>
  end

  @spec encode_fixed_header_second_byte(number) :: binary
  defp encode_fixed_header_second_byte(remaining_length)
    when remaining_length >= 0
    and remaining_length <= 268_435_455 do

      encode_fixed_header_remaining_length(remaining_length)
  end

  @doc """
  Encodes remaining length using a variable length
  encoding scheme specified in MQTT 3.1.1 spec section 2.2.3
  """
  @spec encode_fixed_header_remaining_length(number) :: binary
  def encode_fixed_header_remaining_length(0), do: <<0>>

  def encode_fixed_header_remaining_length(number) when number > 0 do
    encode_fixed_header_remaining_length(number, <<>>)
  end

  @spec encode_fixed_header_remaining_length(number, binary) :: binary
  defp encode_fixed_header_remaining_length(number, accumulator) do
    divisor = 128
    dividend = div(number, divisor)
    remainder = rem(number, divisor)

    if dividend > 0 do
      encodedValue = <<Bitwise.bor(remainder, divisor)>>
      accumulatedValue = accumulator <> encodedValue
      encode_fixed_header_remaining_length(dividend, accumulatedValue)
    else
      encodedValue = <<remainder>>
      accumulator <> encodedValue
    end
  end

  @doc """
  Encodes variable header for a given Message struct
  """
  def encode_variable_header(%Message.Connect{username: username,
                                              password: password,
                                              will_qos: will_qos,
                                              will_retain: will_retain,
                                              will_topic: will_topic,
                                              will_message: will_message,
                                              clean_session: clean_session,
                                              keep_alive: keep_alive}) do
    username_flag = cond do
      byte_size(username) >= 1 -> 1
      byte_size(username) == 0 -> 0
    end

    password_flag = cond do
      byte_size(password) >= 1 -> 1
      byte_size(password) == 0 -> 0
    end

    will_flag = cond do
      (byte_size(will_message) >= 1 and byte_size(will_topic) >= 1) -> 1
      (byte_size(will_message) == 0 and byte_size(will_topic) == 0) -> 0
    end

    <<4::size(16)>> <> "MQTT" <> <<4::size(8)>> <>
      <<username_flag::size(1), password_flag::size(1),
        will_retain::size(1), will_qos::size(2),
        will_flag::size(1), clean_session::size(1), 0::size(1)>> <>
      <<keep_alive::size(16)>>
  end

  def encode_variable_header(%Message.ConnAck{session_present: session_present,
                                              return_code: return_code}) do
    <<0::size(7), session_present::size(1), return_code::size(8)>>
  end

  def encode_variable_header(%Message.Publish{id: id, topic: topic, qos: qos})
  when id <= 65_536 do
    #<<byte_size(topic)::size(16)>> <> topic <> <<id::size(16)>>
    if qos == 0 do
      # no message id if qos = 0
      <<byte_size(topic)::size(16)>> <> topic
    else
      <<byte_size(topic)::size(16)>> <> topic <> <<id::size(16)>>
    end
  end

  def encode_variable_header(%Message.PubAck{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.PubRec{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.PubRel{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.PubComp{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.Subscribe{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.SubAck{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.Unsubscribe{id: id})
    when id <= 65_536 do
      <<id::size(16)>>
  end

  def encode_variable_header(%Message.UnsubAck{id: id})
    when id <= 65_536 do
    <<id::size(16)>>
  end

  @doc """
  Encodes the payload for a given Message struct
  """
  def encode_payload(%Message.Connect{client_id: id,
                                      username: username,
                                      password: password,
                                      will_message: will_message,
                                      will_topic: will_topic}) do

    prefix_length = fn(t) -> (<<byte_size(t)::size(16)>> <> t) end
    prefix_length_if_not_empty = fn(t) ->
      if(byte_size(t) > 0) do
        prefix_length.(t)
      else
        ""
      end
    end

    client_id_load  = prefix_length.(id)
    will_topic_load = prefix_length_if_not_empty.(will_topic)
    will_msg_load   = prefix_length_if_not_empty.(will_message)
    username_load   = prefix_length_if_not_empty.(username)
    password_load   = prefix_length_if_not_empty.(password)

    client_id_load <> will_topic_load <> will_msg_load \
      <> username_load <> password_load
   end

  def encode_payload(%Message.Publish{message: message}) do
    message
  end

  def encode_payload(%Message.Subscribe{topics: topics, requested_qoses: qoses}) do
    pref_length_suf_qos = fn({q,t}) -> (<<byte_size(t)::size(16)>> <> t <> <<q>>) end
    qos_topic_zipmap = Enum.zip(qoses, topics)

    qos_topic_zipmap |> Enum.map_join(pref_length_suf_qos)
  end

  def encode_payload(%Message.SubAck{granted_qoses: qoses}) do
    qoses |> Enum.map_join(fn(q) -> <<q>> end)
  end

  def encode_payload(%Message.Unsubscribe{topics: topics}) do
    prefix_length = fn(t) -> (<<byte_size(t)::size(16)>> <> t) end

    topics |> Enum.map_join(prefix_length)
  end
end
