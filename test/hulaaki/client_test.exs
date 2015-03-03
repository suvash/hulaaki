defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  alias Hulaaki.Client, as: Client
  alias Hulaaki.Message, as: Message

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
    message = Message.connect(client_name, "", "", "", "", 0, 0, 0, 100)
    connection = Client.connect(address, port, message)

    assert %Client.Connection{} = connection

    connection.socket |> Client.disconnect
  end

  def sample_connection do
    address = "localhost"
    port = 1883
    connect_message = Message.connect(client_name, "", "", "", "", 0, 0, 0, 100)
    Client.connect(address, port, connect_message)
  end

  test "publishes a message using a connection" do
    connection = sample_connection

    id = :random.uniform(65_536)
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 1
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    received_publish_ack = connection.socket |> Client.publish message
    assert Message.publish_ack(id) == received_publish_ack

    connection.socket |> Client.disconnect
  end

  test "publishes a message at qos 2 using a connection" do
    connection = sample_connection

    id = :random.uniform(65_536)
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 2
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    received_publish_complete = connection.socket |> Client.publish message
    assert Message.publish_complete(id) == received_publish_complete

    connection.socket |> Client.disconnect
  end

  test "subscribes to topics using a connection" do
    connection = sample_connection

    id = :random.uniform(65_536)
    topics = ["hello","cool"]
    qoses =  [1, 2]
    message = Message.subscribe(id, topics, qoses)

    received_subscribe_ack = connection.socket |> Client.subscribe message
    assert Message.subscribe_ack(id, qoses) == received_subscribe_ack

    connection.socket |> Client.disconnect
  end

  test "unsubscribes from topics using a connection" do
    connection = sample_connection

    id = :random.uniform(65_536)
    topics = ["what"]
    message = Message.unsubscribe(id, topics)

    received_unsubscribe_ack = connection.socket |> Client.unsubscribe message
    assert Message.unsubscribe_ack(id) == received_unsubscribe_ack

    connection.socket |> Client.disconnect
  end

  test "send a ping request using the connection" do
    connection = sample_connection

    message = Message.ping_request
    received_ping_response = connection.socket |> Client.ping message
    assert Message.ping_response == received_ping_response

    received_ping_response = connection.socket |> Client.ping
    assert Message.ping_response == received_ping_response

    connection.socket |> Client.disconnect
  end


end
