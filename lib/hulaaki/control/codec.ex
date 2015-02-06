defmodule Hulaaki.Control.Codec do
  alias Hulaaki.Control.Message, as: Message
  require Bitwise

  @type dup :: 0|1
  @type qos :: 0|1|2
  @type retain :: 0|1
  @type packet_value :: 1|2|3|4|5|6|7|8|9|10|11|12|13|14

  def encode_fixed_header(%Message.Connect{}) do
    encode_generic_fixed_header(1, 0, 0, 0)
  end

  def encode_fixed_header(%Message.ConnAck{}) do
    encode_generic_fixed_header(2, 0, 0, 0)
  end

  def encode_fixed_header(%Message.Publish{dup: dup, qos: qos, retain: retain}) do
    encode_generic_fixed_header(3, dup, qos, retain)
  end

  def encode_fixed_header(%Message.PubAck{}) do
    encode_generic_fixed_header(4, 0, 0, 0)
  end

  def encode_fixed_header(%Message.PubRec{}) do
    encode_generic_fixed_header(5, 0, 0, 0)
  end

  def encode_fixed_header(%Message.PubRel{}) do
    encode_generic_fixed_header(6, 0, 1, 0)
  end

  def encode_fixed_header(%Message.PubComp{}) do
    encode_generic_fixed_header(7, 0, 0, 0)
  end

  def encode_fixed_header(%Message.Subscribe{}) do
    encode_generic_fixed_header(8, 0, 1, 0)
  end

  def encode_fixed_header(%Message.SubAck{}) do
    encode_generic_fixed_header(9, 0, 0, 0)
  end

  def encode_fixed_header(%Message.Unsubscribe{}) do
    encode_generic_fixed_header(10, 0, 1, 0)
  end

  def encode_fixed_header(%Message.UnsubAck{}) do
    encode_generic_fixed_header(11, 0, 0, 0)
  end

  def encode_fixed_header(%Message.PingReq{}) do
    encode_generic_fixed_header(12, 0, 0, 0)
  end

  def encode_fixed_header(%Message.PingResp{}) do
    encode_generic_fixed_header(13, 0, 0, 0)
  end

  def encode_fixed_header(%Message.Disconnect{}) do
    encode_generic_fixed_header(14, 0, 0, 0)
  end

  @spec encode_generic_fixed_header(packet_value, dup, qos, retain) :: binary
  defp encode_generic_fixed_header(packet_value, dup, qos, retain)
    when (packet_value > 0 and packet_value < 15 )
    and (dup == 0 or dup == 1)
    and (qos == 0 or qos == 1 or qos == 2)
    and (retain == 0 or retain == 1) do

      <<packet_value::size(4), dup::size(1), qos::size(2), retain::size(1)>>
  end

  @spec encode_fixed_header_remaining_length(number) :: binary
  def encode_fixed_header_remaining_length(0), do: <<0>>

  def encode_fixed_header_remaining_length(number) when number > 0 do
    encode_fixed_header_remaining_length(number, <<>>)
  end

  @spec encode_fixed_header_remaining_length(number, binary) :: binary
  defp encode_fixed_header_remaining_length(number, accumulator) do
    divisor = 128
    dividend = div(number, divisor )
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
end
