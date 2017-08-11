defmodule Hulaaki.ConnectionSSLTest do
  use ExUnit.Case
  alias Hulaaki.Connection
  alias Hulaaki.Message

  # How to test disconnect message

  defp client_name do
    adjectives = [ "lazy", "funny", "bright", "boring", "crazy", "lonely" ]
    nouns = [ "thermometer", "switch", "scale", "bulb", "heater", "microwave" ]

    id = to_string :rand.uniform(100_000)
    [adjective] = adjectives |> Enum.shuffle |> Enum.take(1)
    [noun] = nouns |> Enum.shuffle |> Enum.take(1)

    adjective <> "-" <> noun <> "-" <> id
  end

  setup do
    {:ok, pid} = Connection.start_link(self())
    {:ok, connection_pid: pid}
  end

  defp pre_connect(pid) do
    message = Message.connect(client_name(), "", "", "", "", 0, 0, 0, 100)
    Connection.connect(pid, message, [host: TestConfig.mqtt_host, port: TestConfig.mqtt_tls_port, timeout: TestConfig.mqtt_timeout, ssl: true])
  end

  defp post_disconnect(pid) do
    Connection.disconnect(pid)
    Connection.stop(pid)
  end

  test "failed ssl connection returns an error tuple", %{connection_pid: pid} do
    message = Message.connect(client_name(), "", "", "", "", 0, 0, 0, 100)

    reply = Connection.connect(pid, message, [host: TestConfig.mqtt_host, port: 7878, timeout: TestConfig.mqtt_timeout, ssl: true])

    assert {:error, :econnrefused} == reply
  end

  test "connect receives ConnAck", %{connection_pid: pid} do
    pre_connect(pid)

    assert_receive {:received, %Message.ConnAck{return_code: 0,
                                    session_present: 0,
                                    type: :CONNACK}}, 10000
    assert_receive {:sent, %Message.Connect{}}, 10000

    post_disconnect(pid)
  end

  test "publish w. qos 1 receives PubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 1122
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 1
    retain = 1
    message = Message.publish(id, topic, message, dup, qos, retain)

    Connection.publish(pid, message)

    assert_receive {:received, %Message.PubAck{id: 1122, type: :PUBACK}}, 10000
    assert_receive {:sent, %Message.Publish{}}, 10000

    post_disconnect(pid)
  end

  test "publish w. qos 2 receives PubRec, publish_release receives PubComp", %{connection_pid: pid} do
    pre_connect(pid)

    id = 2345
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 2
    retain = 1
    publish_message = Message.publish(id, topic, message, dup, qos, retain)

    Connection.publish(pid, publish_message)

    assert_receive {:received, %Message.PubRec{id: 2345, type: :PUBREC}}, 10000
    assert_receive {:sent, %Message.Publish{}}, 10000

    publish_release_message = Message.publish_release(id)

    Connection.publish_release(pid, publish_release_message)

    assert_receive {:received, %Message.PubComp{id: 2345, type: :PUBCOMP}}, 10000
    assert_receive {:sent, %Message.PubRel{}}, 10000

    post_disconnect(pid)
  end

  test "subscribe receives SubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 34875
    topics = ["hello","cool"]
    qoses =  [1, 2]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid, message)

    assert_receive {:received, %Message.SubAck{granted_qoses: [1, 2], id: 34875, type: :SUBACK}}, 10000
    assert_receive {:sent, %Message.Subscribe{}}, 10000

    post_disconnect(pid)
  end

  test "unsubscribe receives UnsubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 19_234
    topics = ["what"]
    message = Message.unsubscribe(id, topics)

    Connection.unsubscribe(pid, message)

    assert_receive {:received, %Message.UnsubAck{id: 19234, type: :UNSUBACK}}, 10000
    assert_receive {:sent, %Message.Unsubscribe{}}, 10000

    post_disconnect(pid)
  end

  test "ping receives PingResp", %{connection_pid: pid} do
    pre_connect(pid)

    Connection.ping(pid)

    assert_receive {:received, %Message.PingResp{type: :PINGRESP}}, 10000
    assert_receive {:sent, %Message.PingReq{}}, 10000

    post_disconnect(pid)
  end

  test "receive messages published to a topic on qos 0 it has subscribed to" do
    {:ok, pid1} = Connection.start_link(self())
    pre_connect(pid1)

    id = :rand.uniform(65_535)
    topics = ["qos0"]
    qoses =  [0]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid1, message)

    spawn fn ->
      {:ok, pid2} = Connection.start_link(self())
      pre_connect(pid2)

      topic = "qos0"
      message = "you better get this message on qos 0"
      dup = 0
      qos = 0
      retain = 0
      message0 = Message.publish(topic, message, dup, qos, retain)
      Connection.publish(pid2, message0)

      post_disconnect(pid2)
    end

    assert_receive {:received, %Message.Publish{dup: 0,qos: 0, retain: 0,
                                    message: "you better get this message on qos 0",
                                    topic: "qos0", type: :PUBLISH}}, 10000

    post_disconnect(pid1)
  end

  test "receive messages published to a topic it has subscribed to on qos 1" do
    {:ok, pid1} = Connection.start_link(self())
    pre_connect(pid1)

    id = :rand.uniform(65_535)
    topics = ["random-topic-8234"]
    qoses =  [1]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid1, message)

    spawn fn ->
      {:ok, pid2} = Connection.start_link(self())
      pre_connect(pid2)

      id = :rand.uniform(65_535)
      topic = "random-topic-8234"
      message = "you better get this message on qos 1"
      dup = 0
      qos = 1
      retain = 0
      message1 = Message.publish(id, topic, message, dup, qos, retain)
      Connection.publish(pid2, message1)

      post_disconnect(pid2)
    end

    assert_receive {:received, %Message.Publish{id: 1, dup: 0,qos: 1, retain: 0,
                                    message: "you better get this message on qos 1",
                                    topic: "random-topic-8234", type: :PUBLISH}}, 10000

    post_disconnect(pid1)
  end

  test "send publish ack after receiving publish messages published to a topic it has subscribed to on qos 1" do
    {:ok, pid1} = Connection.start_link(self())
    pre_connect(pid1)

    id = :rand.uniform(65_535)
    topics = ["random-topic-2850"]
    qoses =  [1]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid1, message)

    spawn fn ->
      {:ok, pid2} = Connection.start_link(self())
      pre_connect(pid2)

      id = :rand.uniform(65_535)
      topic = "random-topic-2850"
      message = "you better get this message on qos 1"
      dup = 0
      qos = 1
      retain = 0
      message1 = Message.publish(id, topic, message, dup, qos, retain)
      Connection.publish(pid2, message1)

      post_disconnect(pid2)
    end

    assert_receive {:received, %Message.Publish{id: 1, dup: 0,qos: 1, retain: 0,
                                    message: "you better get this message on qos 1",
                                    topic: "random-topic-2850", type: :PUBLISH}}, 10000

    message = Message.publish_ack(id)
    Connection.publish_ack(pid1, message)

    assert_receive {:sent, %Message.PubAck{}}, 10000

    post_disconnect(pid1)
  end

end
