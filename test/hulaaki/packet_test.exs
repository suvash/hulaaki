defmodule Hulaaki.PacketTest do
  use ExUnit.Case
	alias Hulaaki.Packet, as: Packet

  test "control packet fixed header for CONNECT" do
    received = Packet.control_packet_fixed_header(:CONNECT)
    expected = <<1::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for CONNACK" do
    received = Packet.control_packet_fixed_header(:CONNACK)
    expected = <<2::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PUBLISH" do
    received = Packet.control_packet_fixed_header(:PUBLISH)
    expected = <<3::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PUBACK" do
    received = Packet.control_packet_fixed_header(:PUBACK)
    expected = <<4::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PUBREC" do
    received = Packet.control_packet_fixed_header(:PUBREC)
    expected = <<5::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PUBREL" do
    received = Packet.control_packet_fixed_header(:PUBREL)
    expected = <<6::size(4), 0::size(1), 0::size(1), 1::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PUBCOMP" do
    received = Packet.control_packet_fixed_header(:PUBCOMP)
    expected = <<7::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for SUBSCRIBE" do
    received = Packet.control_packet_fixed_header(:SUBSCRIBE)
    expected = <<8::size(4), 0::size(1), 0::size(1), 1::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for SUBACK" do
    received = Packet.control_packet_fixed_header(:SUBACK)
    expected = <<9::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for UNSUBSCRIBE" do
    received = Packet.control_packet_fixed_header(:UNSUBSCRIBE)
    expected = <<10::size(4), 0::size(1), 0::size(1), 1::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for UNSUBACK" do
    received = Packet.control_packet_fixed_header(:UNSUBACK)
    expected = <<11::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PINGREC" do
    received = Packet.control_packet_fixed_header(:PINGREC)
    expected = <<12::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for PINGRESP" do
    received = Packet.control_packet_fixed_header(:PINGRESP)
    expected = <<13::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end

  test "control packet fixed header for DISCONNECT" do
    received = Packet.control_packet_fixed_header(:DISCONNECT)
    expected = <<14::size(4), 0::size(1), 0::size(1), 0::size(1), 0::size(1)>>

    assert expected == received
  end
end
