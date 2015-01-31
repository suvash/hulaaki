defmodule Hulaaki.Control.PacketTest do
  use ExUnit.Case
  alias Hulaaki.Control.Packet, as: Packet

  test "invalid packet type" do
    expected = Packet.valid? %Packet{type: :NONSENSE}
    refute expected
  end

  test "CONNECT packet type is valid" do
    assert Packet.valid?(%Packet{type: :CONNECT})
  end

  test "CONNACK packet type is valid" do
    assert Packet.valid?(%Packet{type: :CONNACK})
  end

  test "PUBLISH packet type is valid" do
    assert Packet.valid?(%Packet{type: :PUBLISH})
  end

  test "PUBACK packet type is valid" do
    assert Packet.valid?(%Packet{type: :PUBACK})
  end

  test "PUBREC packet type is valid" do
    assert Packet.valid?(%Packet{type: :PUBREC})
  end

  test "PUBREL packet type is valid" do
    assert Packet.valid?(%Packet{type: :PUBREL})
  end

  test "PUBCOMP packet type is valid" do
    assert Packet.valid?(%Packet{type: :PUBCOMP})
  end

  test "SUBSCRIBE packet type is valid" do
    assert Packet.valid?(%Packet{type: :SUBSCRIBE})
  end

  test "SUBACK packet type is valid" do
    assert Packet.valid?(%Packet{type: :SUBACK})
  end

  test "UNSUBSCRIBE packet type is valid" do
    assert Packet.valid?(%Packet{type: :UNSUBSCRIBE})
  end

  test "UNSUBACK packet type is valid" do
    assert Packet.valid?(%Packet{type: :UNSUBACK})
  end

  test "PINGREC packet type is valid" do
    assert Packet.valid?(%Packet{type: :PINGREC})
  end

  test "PINGRESP packet type is valid" do
    assert Packet.valid?(%Packet{type: :PINGRESP})
  end

  test "DISCONNECT packet type is valid" do
    assert Packet.valid?(%Packet{type: :DISCONNECT})
  end
end
