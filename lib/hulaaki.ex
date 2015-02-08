defmodule Hulaaki do
  alias Hulaaki.Message, as: Message
  alias Hulaaki.Codec, as: Codec

  defprotocol Packet do
    def encode(message)
  end

  defimpl Packet, for: Message.Connect do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.ConnAck do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.Publish do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PubAck do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PubRec do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PubRel do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PubComp do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.Subscribe do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.SubAck do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.Unsubscribe do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.UnsubAck do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PingReq do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.PingResp do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end

  defimpl Packet, for: Message.Disconnect do
    def encode(message) do
      Codec.encode_fixed_header(message)
    end
  end
end
