defmodule Hulaaki.Control.Codec do

  @doc "As described in Figure 2.2 in MQTT-3.1.1-os specification"
  def encode_fixed_header(packet) do
    [bit_3, bit_2, bit_1, bit_0] = encode_fixed_header_flag_bits(packet.type)
    bitstring_7_4 = encode_fixed_header_type_value(packet.type)

    <<bitstring_7_4::size(4), bit_3::size(1), bit_2::size(1),
      bit_1::size(1), bit_0::size(1)>>
  end

  "As described in Fig 2.2/Table 2.1/Section 2.2.1 in MQTT-3.1.1-os specification"
  # def encode_type_value(:reserved_0),     do: 0
  # def encode_type_value(:reserved_15),    do: 15
  defp encode_fixed_header_type_value(type) do
    case type do
      :CONNECT     -> 1
      :CONNACK     -> 2
      :PUBLISH     -> 3
      :PUBACK      -> 4
      :PUBREC      -> 5
      :PUBREL      -> 6
      :PUBCOMP     -> 7
      :SUBSCRIBE   -> 8
      :SUBACK      -> 9
      :UNSUBSCRIBE -> 10
      :UNSUBACK    -> 11
      :PINGREC     -> 12
      :PINGRESP    -> 13
      :DISCONNECT  -> 14
    end
  end

  "As described in Fig 2.2/Table 2.2/Section 2.2.2 in MQTT-3.1.1-os specification"
  defp encode_fixed_header_flag_bits(type) do
    case type do
      :CONNECT     -> [0,0,0,0]
      :CONNACK     -> [0,0,0,0]
      :PUBLISH     -> [0,0,0,0] # FIX THIS
      :PUBACK      -> [0,0,0,0]
      :PUBREC      -> [0,0,0,0]
      :PUBREL      -> [0,0,1,0]
      :PUBCOMP     -> [0,0,0,0]
      :SUBSCRIBE   -> [0,0,1,0]
      :SUBACK      -> [0,0,0,0]
      :UNSUBSCRIBE -> [0,0,1,0]
      :UNSUBACK    -> [0,0,0,0]
      :PINGREC     -> [0,0,0,0]
      :PINGRESP    -> [0,0,0,0]
      :DISCONNECT  -> [0,0,0,0]
    end
  end
end
