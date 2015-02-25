defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  alias Hulaaki.Client, as: Client

  defp disconnect(connection) do
    packet = Hulaaki.Message.disconnect |> Hulaaki.Packet.encode
    connection.socket |> Socket.Stream.send! packet
  end

  test "establishes valid connection" do
    address = "localhost"
    port = 1883
    client_id = "random-client-is-mad"
    connection = Client.connect(address, port, client_id)

    assert %Client.Connection{} = connection

    disconnect(connection)
  end

end
