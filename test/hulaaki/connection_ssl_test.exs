defmodule Hulaaki.ConnectionSSLTest do
  use ExUnit.Case, async: true
  alias Hulaaki.Connection
  alias Hulaaki.Message

  setup do
    {:ok, pid} = Connection.start(self())
    {:ok, connection_pid: pid}
  end

  defp pre_connect(pid) do
    message = Message.connect(TestHelper.random_name(), "", "", "", "", 0, 0, 0, 100)

    :ok =
      Connection.connect(
        pid,
        message,
        host: TestConfig.mqtt_host(),
        port: TestConfig.mqtt_tls_port(),
        timeout: TestConfig.mqtt_timeout(),
        ssl: TestConfig.ssl_options()
      )
  end

  defp post_disconnect(pid) do
    Connection.disconnect(pid)
    Connection.stop(pid)
  end

  test "failed ssl connection returns an error tuple", %{connection_pid: pid} do
    message = Message.connect(TestHelper.random_name(), "", "", "", "", 0, 0, 0, 100)

    reply =
      Connection.connect(
        pid,
        message,
        host: TestConfig.mqtt_host(),
        port: 7878,
        timeout: TestConfig.mqtt_timeout(),
        ssl: TestConfig.ssl_options()
      )

    assert {:error, :econnrefused} == reply
  end

  test "connect receives ConnAck", %{connection_pid: pid} do
    pre_connect(pid)

    assert_receive {:received,
                    %Message.ConnAck{return_code: 0, session_present: 0, type: :CONNACK}}

    assert_receive {:sent, %Message.Connect{}}

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

    assert_receive {:received, %Message.PubAck{id: 1122, type: :PUBACK}}
    assert_receive {:sent, %Message.Publish{}}

    post_disconnect(pid)
  end

  test "publish w. qos 2 receives PubRec, publish_release receives PubComp", %{
    connection_pid: pid
  } do
    pre_connect(pid)

    id = 2345
    topic = "a/b"
    message = "a short message"
    dup = 0
    qos = 2
    retain = 1
    publish_message = Message.publish(id, topic, message, dup, qos, retain)

    Connection.publish(pid, publish_message)

    assert_receive {:received, %Message.PubRec{id: 2345, type: :PUBREC}}
    assert_receive {:sent, %Message.Publish{}}

    publish_release_message = Message.publish_release(id)

    Connection.publish_release(pid, publish_release_message)

    assert_receive {:received, %Message.PubComp{id: 2345, type: :PUBCOMP}}
    assert_receive {:sent, %Message.PubRel{}}

    post_disconnect(pid)
  end

  test "subscribe receives SubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 34875
    topics = ["hello", "cool"]
    qoses = [1, 2]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid, message)

    assert_receive {:received, %Message.SubAck{granted_qoses: [1, 2], id: 34875, type: :SUBACK}}
    assert_receive {:sent, %Message.Subscribe{}}

    post_disconnect(pid)
  end

  test "unsubscribe receives UnsubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 19_234
    topics = ["what"]
    message = Message.unsubscribe(id, topics)

    Connection.unsubscribe(pid, message)

    assert_receive {:received, %Message.UnsubAck{id: 19234, type: :UNSUBACK}}
    assert_receive {:sent, %Message.Unsubscribe{}}

    post_disconnect(pid)
  end

  test "ping receives PingResp", %{connection_pid: pid} do
    pre_connect(pid)

    Connection.ping(pid)

    assert_receive {:received, %Message.PingResp{type: :PINGRESP}}
    assert_receive {:sent, %Message.PingReq{}}

    post_disconnect(pid)
  end
end
