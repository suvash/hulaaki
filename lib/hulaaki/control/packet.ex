defmodule Hulaaki.Control.Packet do
  @type type :: atom
  @type t :: %__MODULE__{type: type}

  defstruct [:type]

  @valid_types Enum.into([:CONNECT,
                          :CONNACK,
                          :PUBLISH,
                          :PUBACK,
                          :PUBREC,
                          :PUBREL,
                          :PUBCOMP,
                          :SUBSCRIBE,
                          :SUBACK,
                          :UNSUBSCRIBE,
                          :UNSUBACK,
                          :PINGREC,
                          :PINGRESP,
                          :DISCONNECT
                         ], HashSet.new)

  @spec valid?(t) :: boolean
  def valid?(packet) do
    valid_type?(packet)
  end

  @spec valid_type?(t) :: boolean
  defp valid_type?(packet) do
    Set.member?(@valid_types, packet.type)
  end
end
