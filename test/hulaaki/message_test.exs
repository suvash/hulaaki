defmodule Hulaaki.MessageTest do
  use ExUnit.Case
  alias Hulaaki.Message

  test "connect build a Connect message struct" do
    id = "test-client-id"
    username = "test-user"
    password = "test-password"
    will_topic = ""
    will_message = ""
    will_qos = 0
    will_retain = 1
    clean_session = 0
    keep_alive = 10
    expected = %Message.Connect{client_id: id,
                                username: username,
                                password: password,
                                will_topic: will_topic,
                                will_message: will_message,
                                will_qos: will_qos,
                                will_retain: will_retain,
                                clean_session: clean_session,
                                keep_alive: keep_alive}
    received = Message.connect(id, username, password,
                               will_topic, will_message, will_qos,
                               will_retain, clean_session, keep_alive)

    assert expected == received
  end

  test "connect_ack builds a ConnAck message struct" do
    session_present = 0
    return_code = 3
    expected = %Message.ConnAck{session_present: session_present,
                                return_code: return_code}
    received = Message.connect_ack(session_present, return_code)

    assert expected == received
  end

  test "publish builds a Publish message struct" do
    id = :rand.uniform(65_535)
    topic = "nice_topic"
    message = " a short message"
    dup = 0
    qos = 2
    retain = 1
    expected = %Message.Publish{id: id, topic: topic,
                                message: message, dup: dup,
                                qos: qos, retain: retain}
    received = Message.publish(id, topic, message, dup, qos, retain)

    assert expected == received
  end

  test "publish builds a Publish message struct without packet id when qos 0" do
    id = :rand.uniform(65_535)
    topic = "nice_topic"
    message = " a short message"
    dup = 0
    qos = 0
    retain = 1
    expected = %Message.Publish{topic: topic,
                                message: message, dup: dup,
                                qos: qos, retain: retain}
    received_1 = Message.publish(id, topic, message, dup, qos, retain)
    received_2 = Message.publish(topic, message, dup, qos, retain)

    assert expected == received_1
    assert expected == received_2
  end

  test "publish_ack builds a PubAck message struct" do
    id = :rand.uniform(65_535)
    expected = %Message.PubAck{id: id}
    received = Message.publish_ack(id)

    assert expected == received
  end

  test "publish_received builds a PubRec message struct" do
    id = :rand.uniform(65_535)
    expected = %Message.PubRec{id: id}
    received = Message.publish_receive(id)

    assert expected == received
  end

  test "publish_release builds a PubRel message struct" do
    id = :rand.uniform(65_535)
    expected = %Message.PubRel{id: id}
    received = Message.publish_release(id)

    assert expected == received
  end

  test "publish_complete builds a PubComp message struct" do
    id = :rand.uniform(65_535)
    expected = %Message.PubComp{id: id}
    received = Message.publish_complete(id)

    assert expected == received
  end

  test "subscribe build a Subscribe message struct" do
    # topics and req_qoses must have equal length
    id = :rand.uniform(65_535)
    topics = ["hello","cool"]
    qoses = [0, 1]
    expected = %Message.Subscribe{id: id,
                                  topics: ["hello", "cool"],
                                  requested_qoses: [0, 1]}
    received = Message.subscribe(id, topics, qoses)

    assert expected == received

  end

  test "subscribe_ack builds a SubAck message struct" do
    id = :rand.uniform(65_535)
    qoses = ["hello", -1, 0, 1, 2, 3, 12.34, 5, 123, 128]
    expected = %Message.SubAck{id: id, granted_qoses: [0, 1, 2, 128]}
    received = Message.subscribe_ack(id, qoses)

    assert expected == received
  end

  test "unsubscribe builds a Unsubscribe message struct" do
    id = :rand.uniform(65_535)
    topics = [1,2,"hello","cool"]
    expected = %Message.Unsubscribe{id: id, topics: ["hello", "cool"]}
    received = Message.unsubscribe(id, topics)

    assert expected == received
  end

  test "unsubscribe_ack builds a UnsubAck message struct" do
    id = :rand.uniform(65_535)
    expected = %Message.UnsubAck{id: id}
    received = Message.unsubscribe_ack(id)

    assert expected == received
  end

  test "ping_request builds a PingReq message struct" do
    expected = %Message.PingReq{}
    received = Message.ping_request

    assert expected == received
  end

  test "ping_response builds a PingResponse message struct" do
    expected = %Message.PingResp{}
    received = Message.ping_response

    assert expected == received
  end

  test "disconnect builds a Disconnect message struct" do
    expected = %Message.Disconnect{}
    received = Message.disconnect

    assert expected == received
  end
end
