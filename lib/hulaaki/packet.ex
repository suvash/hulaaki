defmodule Hulaaki.Packet do

  @doc "As described in Figure 2.2 in MQTT-3.1.1-os specification"
  def control_packet_fixed_header(packet_type) do
    [bit_3, bit_2, bit_1, bit_0] = control_packet_flag_bits(packet_type)
    bitstring_7_4 = control_packet_type_value(packet_type)

    <<bitstring_7_4::size(4), bit_3::size(1), bit_2::size(1),
      bit_1::size(1), bit_0::size(1)>>
  end

  "As described in Table 2.2.1 in MQTT-3.1.1-os specification"
  # def control_packet_type_value(:reserved_0),     do: 0
  defp control_packet_type_value(:CONNECT),     do: 1
  defp control_packet_type_value(:CONNACK),     do: 2
  defp control_packet_type_value(:PUBLISH),     do: 3
  defp control_packet_type_value(:PUBACK),      do: 4
  defp control_packet_type_value(:PUBREC),      do: 5
  defp control_packet_type_value(:PUBREL),      do: 6
  defp control_packet_type_value(:PUBCOMP),     do: 7
  defp control_packet_type_value(:SUBSCRIBE),   do: 8
  defp control_packet_type_value(:SUBACK),      do: 9
  defp control_packet_type_value(:UNSUBSCRIBE), do: 10
  defp control_packet_type_value(:UNSUBACK),    do: 11
  defp control_packet_type_value(:PINGREC),     do: 12
  defp control_packet_type_value(:PINGRESP),    do: 13
  defp control_packet_type_value(:DISCONNECT),  do: 14
  # def control_packet_type_value(:reserved_15),  do: 15


  "As described in Table 2.2 in MQTT-3.1.1-os specification"
  defp control_packet_flag_bits(:CONNECT),     do: [0,0,0,0]
  defp control_packet_flag_bits(:CONNACK),     do: [0,0,0,0]
  defp control_packet_flag_bits(:PUBLISH),     do: [0,0,0,0] # FIX THIS
  defp control_packet_flag_bits(:PUBACK),      do: [0,0,0,0]
  defp control_packet_flag_bits(:PUBREC),      do: [0,0,0,0]
  defp control_packet_flag_bits(:PUBREL),      do: [0,0,1,0]
  defp control_packet_flag_bits(:PUBCOMP),     do: [0,0,0,0]
  defp control_packet_flag_bits(:SUBSCRIBE),   do: [0,0,1,0]
  defp control_packet_flag_bits(:SUBACK),      do: [0,0,0,0]
  defp control_packet_flag_bits(:UNSUBSCRIBE), do: [0,0,1,0]
  defp control_packet_flag_bits(:UNSUBACK),    do: [0,0,0,0]
  defp control_packet_flag_bits(:PINGREC),     do: [0,0,0,0]
  defp control_packet_flag_bits(:PINGRESP),    do: [0,0,0,0]
  defp control_packet_flag_bits(:DISCONNECT),  do: [0,0,0,0]
end
