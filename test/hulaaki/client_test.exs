defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  alias Hulaaki.Client, as: Client

  defp disconnect(connection) do
    packet = Hulaaki.Message.disconnect |> Hulaaki.Packet.encode
    connection.socket |> Socket.Stream.send! packet
  end

  defp client_name do
    adjectives = [ "lazy", "funny", "bright", "boring", "crazy", "lonely" ]
    nouns = [ "thermometer", "switch", "scale", "bulb", "heater", "microwave" ]

    :random.seed(:os.timestamp)
    [adjective] = adjectives |> Enum.shuffle |> Enum.take 1
    [noun] = nouns |> Enum.shuffle |> Enum.take 1

    adjective <> "-" <> noun
  end

  test "establishes valid connection" do
    address = "localhost"
    port = 1883
    client_id = client_name
    connection = Client.connect(address, port, client_id)

    assert %Client.Connection{} = connection

    disconnect(connection)
  end

end
