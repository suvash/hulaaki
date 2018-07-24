defmodule Hulaaki.ConnectionSSLTest do
  use ExUnit.Case
  alias Hulaaki.Connection
  alias Hulaaki.Message

  @ssl_options [
    ciphers: [
      %{cipher: :"3des_ede_cbc", key_exchange: :rsa, mac: :sha, prf: :default_prf}
    ]
  ]

  # How to test disconnect message

  defp client_name do
    adjectives = ["lazy", "funny", "bright", "boring", "crazy", "lonely"]
    nouns = ["thermometer", "switch", "scale", "bulb", "heater", "microwave"]

    id = to_string(:rand.uniform(100_000))
    [adjective] = adjectives |> Enum.shuffle() |> Enum.take(1)
    [noun] = nouns |> Enum.shuffle() |> Enum.take(1)

    adjective <> "-" <> noun <> "-" <> id
  end

  setup do
    {:ok, pid} = Connection.start_link(self())
    {:ok, connection_pid: pid}
  end

  defp pre_connect(pid) do
    message = Message.connect(client_name(), "", "", "", "", 0, 0, 0, 100)

    :ok =
      Connection.connect(
        pid,
        message,
        host: TestConfig.mqtt_host(),
        port: TestConfig.mqtt_tls_port(),
        timeout: TestConfig.mqtt_timeout(),
        ssl: @ssl_options
      )
  end

  defp post_disconnect(pid) do
    Connection.disconnect(pid)
    Connection.stop(pid)
  end

  test "failed ssl connection returns an error tuple", %{connection_pid: pid} do
    message = Message.connect(client_name(), "", "", "", "", 0, 0, 0, 100)

    reply =
      Connection.connect(
        pid,
        message,
        host: TestConfig.mqtt_host(),
        port: 7878,
        timeout: TestConfig.mqtt_timeout(),
        ssl: @ssl_options
      )

    assert {:error, :econnrefused} == reply
  end

  test "connect receives ConnAck", %{connection_pid: pid} do
    pre_connect(pid)

    assert_receive {:received,
                    %Message.ConnAck{return_code: 0, session_present: 0, type: :CONNACK}},
                   30_000

    assert_receive {:sent, %Message.Connect{}}, 30_000

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

    assert_receive {:received, %Message.PubAck{id: 1122, type: :PUBACK}}, 30_000
    assert_receive {:sent, %Message.Publish{}}, 30_000

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

    assert_receive {:received, %Message.PubRec{id: 2345, type: :PUBREC}}, 30_000
    assert_receive {:sent, %Message.Publish{}}, 30_000

    publish_release_message = Message.publish_release(id)

    Connection.publish_release(pid, publish_release_message)

    assert_receive {:received, %Message.PubComp{id: 2345, type: :PUBCOMP}}, 30_000
    assert_receive {:sent, %Message.PubRel{}}, 30_000

    post_disconnect(pid)
  end

  test "subscribe receives SubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 34875
    topics = ["hello", "cool"]
    qoses = [1, 2]
    message = Message.subscribe(id, topics, qoses)

    Connection.subscribe(pid, message)

    assert_receive {:received, %Message.SubAck{granted_qoses: [1, 2], id: 34875, type: :SUBACK}},
                   30_000

    assert_receive {:sent, %Message.Subscribe{}}, 30_000

    post_disconnect(pid)
  end

  test "unsubscribe receives UnsubAck", %{connection_pid: pid} do
    pre_connect(pid)

    id = 19_234
    topics = ["what"]
    message = Message.unsubscribe(id, topics)

    Connection.unsubscribe(pid, message)

    assert_receive {:received, %Message.UnsubAck{id: 19234, type: :UNSUBACK}}, 30_000
    assert_receive {:sent, %Message.Unsubscribe{}}, 30_000

    post_disconnect(pid)
  end

  test "ping receives PingResp", %{connection_pid: pid} do
    pre_connect(pid)

    Connection.ping(pid)

    assert_receive {:received, %Message.PingResp{type: :PINGRESP}}, 30_000
    assert_receive {:sent, %Message.PingReq{}}, 30_000

    post_disconnect(pid)
  end
end
