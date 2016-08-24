defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  alias Hulaaki.Message

  defmodule SampleClient do
    use Hulaaki.Client

    def on_connect(message: message, state: state) do
      Kernel.send state.parent, {:connect, message}
    end

    def on_connect_ack(message: message, state: state) do
      Kernel.send state.parent, {:connect_ack, message}
    end

    def on_publish(message: message, state: state) do
      Kernel.send state.parent, {:publish, message}
    end

    def on_subscribed_publish(message: message, state: state) do
      Kernel.send state.parent, {:subscribed_publish, message}
    end

    def on_subscribed_publish_ack(message: message, state: state) do
      Kernel.send state.parent, {:subscribed_publish_ack, message}
    end

    def on_publish_receive(message: message, state: state) do
      Kernel.send state.parent, {:publish_receive, message}
    end

    def on_publish_release(message: message, state: state) do
      Kernel.send state.parent, {:publish_release, message}
    end

    def on_publish_complete(message: message, state: state) do
      Kernel.send state.parent, {:publish_complete, message}
    end

    def on_publish_ack(message: message, state: state) do
      Kernel.send state.parent, {:publish_ack, message}
    end

    def on_subscribe(message: message, state: state) do
      Kernel.send state.parent, {:subscribe, message}
    end

    def on_subscribe_ack(message: message, state: state) do
      Kernel.send state.parent, {:subscribe_ack, message}
    end

    def on_unsubscribe(message: message, state: state) do
      Kernel.send state.parent, {:unsubscribe, message}
    end

    def on_unsubscribe_ack(message: message, state: state) do
      Kernel.send state.parent, {:unsubscribe_ack, message}
    end

    def on_ping(message: message, state: state) do
      Kernel.send state.parent, {:ping, message}
    end

    def on_ping_response(message: message, state: state) do
      Kernel.send state.parent, {:ping_response, message}
    end

    def on_ping_response_timeout(message: message, state: state) do
      Kernel.send state.parent, {:ping_response_timeout, message}
    end

    def on_disconnect(message: message, state: state) do
      Kernel.send state.parent, {:disconnect, message}
    end
  end

  defmodule HackPingResponseClient do
    use Hulaaki.Client

    def on_ping(message: message, state: state) do
      Kernel.send state.parent, {:ping, message}
    end

    def on_ping_response(_) do
      Kernel.send(self(), {:ping_response_timeout})
    end

    def on_ping_response_timeout(message: _, state: state) do
      Kernel.send state.parent, {:ping_response_timeout}
    end
  end

  setup do
    {:ok, pid} = SampleClient.start_link(%{parent: self()})
    {:ok, client_pid: pid}
  end

  defp pre_connect(pid) do
    options = [client_id: "some-name" <> Integer.to_string(:rand.uniform(10_000)),
               host: TestConfig.mqtt_host, port: TestConfig.mqtt_port, timeout: 200]
    SampleClient.connect(pid, options)
  end

  defp post_disconnect(pid) do
    SampleClient.disconnect(pid)
    SampleClient.stop(pid)
  end

  test "error message when sending connect on connection failure", %{client_pid: pid} do
    options = [client_id: "some-name-1974", host: TestConfig.mqtt_host, port: 7878, timeout: 200]

    reply = SampleClient.connect(pid, options)

    assert {:error, :econnrefused} == reply
  end

  test "on_connect callback on sending connect", %{client_pid: pid} do
    pre_connect pid

    assert_receive {:connect, %Message.Connect{}}

    post_disconnect pid
  end

  test "on_connect_ack callback on receiving connect_ack", %{client_pid: pid} do
    pre_connect pid

    assert_receive {:connect_ack, %Message.ConnAck{}}

    post_disconnect pid
  end

  test "on_disconnect callback on sending disconnect", %{client_pid: pid} do
    pre_connect pid

    SampleClient.disconnect(pid)
    assert_receive {:disconnect, %Message.Disconnect{}}

    SampleClient.stop(pid)
  end

  test "on_publish callback on sending publish", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 1, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish, %Message.Publish{}}

    post_disconnect pid
  end

  test "on_publish callback on sending publish w. qos 0", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 0, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish, %Message.Publish{}}

    post_disconnect pid
  end

  test "on_publish_ack callback on receiving publish_ack", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 1, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish_ack, %Message.PubAck{}}

    post_disconnect pid
  end

  test "on_publish_receive callback on receiving publish_receive", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish_receive, %Message.PubRec{}}

    post_disconnect pid
  end

  test "on_publish_release callback on sending publish_release", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish_release, %Message.PubRel{}}

    post_disconnect pid
  end

  test "on_publish_complete callback on receiving publish_complete", %{client_pid: pid} do
    pre_connect pid

    options = [topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    SampleClient.publish(pid, options)
    assert_receive {:publish_complete, %Message.PubComp{}}

    post_disconnect pid
  end

  test "on_subscribe callback on sending subscribe", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["a/b", "c/d"], qoses: [0, 1]]
    SampleClient.subscribe(pid, options)
    assert_receive {:subscribe, %Message.Subscribe{}}

    post_disconnect pid
  end

  test "on_subscribe_ack callback on receiving subscribe_ack", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["a/b", "c/d"], qoses: [0, 1]]
    SampleClient.subscribe(pid, options)
    assert_receive {:subscribe_ack, %Message.SubAck{}}

    post_disconnect pid
  end

  test "on_unsubscribe callback on sending unsubscribe", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["a/d", "c/f"]]
    SampleClient.unsubscribe(pid, options)
    assert_receive {:unsubscribe, %Message.Unsubscribe{}}

    post_disconnect pid
  end

  test "on_unsubscribe_ack callback on receiving unsubscribe_ack", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["a/d", "c/f"]]
    SampleClient.unsubscribe(pid, options)
    assert_receive {:unsubscribe_ack, %Message.UnsubAck{}}

    post_disconnect pid
  end

  test "on_ping callback on sending ping", %{client_pid: pid} do
    pre_connect pid

    SampleClient.ping(pid)
    assert_receive {:ping, %Message.PingReq{}}

    post_disconnect pid
  end

  test "on_ping_response callback on receiving ping_resp", %{client_pid: pid} do
    pre_connect pid

    SampleClient.ping(pid)
    assert_receive {:ping_response, %Message.PingResp{}}

    post_disconnect pid
  end

  test "receives ping (and hence ping_response) after keep_alive timeout on idle connection" do
    {:ok, pid} = SampleClient.start_link(%{parent: self()})

    options = [client_id: "some-name-6379", host: TestConfig.mqtt_host, port: TestConfig.mqtt_port,
               keep_alive: 2, timeout: 200]
    SampleClient.connect(pid, options)

    assert_receive({:ping, %Message.PingReq{}}, 4_000)
    assert_receive({:ping_response, %Message.PingResp{}}, 4_000)

    post_disconnect pid
  end

  test "receives ping response timeout after the ping response timeout" do
    {:ok, pid} =  HackPingResponseClient.start_link(%{parent: self()})

    options = [client_id: "ping-response-7402", host: TestConfig.mqtt_host, port: TestConfig.mqtt_port,
               keep_alive: 2, timeout: 200]
    HackPingResponseClient.connect(pid, options)

    assert_receive({:ping_response_timeout}, 8_000)

    post_disconnect pid
  end

  test "on_subscribed_publish callback on receiving publish on subscribed topic", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["awesome"], qoses: [0]]
    SampleClient.subscribe(pid, options)

    spawn fn ->
      {:ok, pid2} = SampleClient.start_link(%{parent: self()})

      options = [client_id: "another-name-7592", host: TestConfig.mqtt_host, port: TestConfig.mqtt_port]
      SampleClient.connect(pid2, options)

      options = [topic: "awesome", message: "a message",
                 dup: 0, qos: 0, retain: 1]
      SampleClient.publish(pid2, options)

      post_disconnect pid2
    end

    assert_receive {:subscribed_publish, %Message.Publish{}}

    post_disconnect pid
  end

  test "on_subscribed_publish_ack callback on sending publish ack after receiving publish on a subscribed topic", %{client_pid: pid} do
    pre_connect pid

    options = [topics: ["awesome"], qoses: [1]]
    SampleClient.subscribe(pid, options)

    spawn fn ->
      {:ok, pid2} = SampleClient.start_link(%{parent: self()})

      options = [client_id: "another-name-8234", host: TestConfig.mqtt_host, port: TestConfig.mqtt_port]
      SampleClient.connect(pid2, options)

      options = [topic: "awesome", message: "a message",
                 dup: 0, qos: 1, retain: 1]
      SampleClient.publish(pid2, options)

      post_disconnect pid2
    end

    assert_receive {:subscribed_publish_ack, %Message.PubAck{}}

    post_disconnect pid
  end

end
