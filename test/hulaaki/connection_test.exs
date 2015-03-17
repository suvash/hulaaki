defmodule Hulaaki.ConnectionTest do
  use ExUnit.Case
  alias Hulaaki.Connection
  alias Hulaaki.Message

  # How to test disconnect message

  defp client_name do
    adjectives = [ "lazy", "funny", "bright", "boring", "crazy", "lonely" ]
    nouns = [ "thermometer", "switch", "scale", "bulb", "heater", "microwave" ]

    :random.seed(:os.timestamp)
    id = to_string :random.uniform(100_000)
    [adjective] = adjectives |> Enum.shuffle |> Enum.take 1
    [noun] = nouns |> Enum.shuffle |> Enum.take 1

    adjective <> "-" <> noun <> "-" <> id
  end

  setup do
    {:ok, pid} = Connection.start_link(self)
    {:ok, client_pid: pid}
  end

  defp pre_connect(pid) do
    message = Message.connect(client_name, "", "", "", "", 0, 0, 0, 100)
    Connection.connect(pid, message)
  end

  defp post_disconnect(pid) do
    Connection.disconnect(pid)
    Connection.stop(pid)
  end

  test "connect receives ConnAck", %{client_pid: pid} do
    pre_connect(pid)

    assert_receive %Message.ConnAck{return_code: 0,
                                    session_present: 0,
                                    type: :CONNACK}, 500

    post_disconnect(pid)
  end

  test "publish receives PubAck", %{client_pid: pid} do
    pre_connect(pid)

    id = 1122
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 1
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    Connection.publish(pid, message)

    assert_receive %Message.PubAck{id: 1122, type: :PUBACK}, 500

    post_disconnect(pid)
  end

  test "publish w. qos 2 receives PubRec, publish_release receives PubComp", %{client_pid: pid} do
    pre_connect(pid)

    id = 2345
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 2
    retain = 1
    publish_message = Message.publish(id, topic, message, dup, qos, retain)

    Connection.publish(pid, publish_message)

    assert_receive %Message.PubRec{id: 2345, type: :PUBREC}, 500

    publish_release_message = Message.publish_release(id)

    Connection.publish_release(pid, publish_release_message)

    assert_receive %Message.PubComp{id: 2345, type: :PUBCOMP}, 500

    post_disconnect(pid)
  end

  test "subscribe receives SubAck", %{client_pid: pid} do
    pre_connect(pid)

    id = 34875
    topics = ["hello","cool"]
    qoses =  [1, 2]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid, message)

    assert_receive %Message.SubAck{granted_qoses: [1, 2], id: 34875, type: :SUBACK}, 500

    post_disconnect(pid)
  end

  test "unsubscribe receives UnsubAck", %{client_pid: pid} do
    pre_connect(pid)

    id = 19_234
    topics = ["what"]
    message = Message.unsubscribe(id, topics)

    Connection.unsubscribe(pid, message)

    assert_receive %Message.UnsubAck{id: 19234, type: :UNSUBACK}, 500

    post_disconnect(pid)
  end

  test "ping receives PingResp", %{client_pid: pid} do
    pre_connect(pid)

    Connection.ping(pid)

    assert_receive %Message.PingResp{type: :PINGRESP}, 500

    post_disconnect(pid)
  end

  test "receive messages published to a topic it has subscribed to" do
    {:ok, pid1} = Connection.start_link(self)
    pre_connect(pid1)

    id = :random.uniform(65_536)
    topics = ["common"]
    qoses =  [1]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid1, message)

    spawn fn ->
      {:ok, pid2} = Connection.start_link(self)
      pre_connect(pid2)

      id = :random.uniform(65_536)
      topic = "common"
      message = "you better get this message"
      dup = 0
      qos = 1
      retain = 0
      message = Message.publish(id, topic, message, dup, qos, retain)

      Connection.publish(pid2, message)

      post_disconnect(pid2)
    end

    assert_receive %Message.Publish{id: 1, dup: 0,qos: 1, retain: 0,
                                    message: "you better get this message",
                                    topic: "common", type: :PUBLISH}, 500

    post_disconnect(pid1)
  end

end
