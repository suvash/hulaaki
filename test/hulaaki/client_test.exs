defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  alias Hulaaki.Message

  # configure the mqtt server
  @mqtt_host "192.168.16.62"
  @mqtt_port 1883
  
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

    def on_pong(message: message, state: state) do
      Kernel.send state.parent, {:pong, message}
    end

    def on_disconnect(message: message, state: state) do
      Kernel.send state.parent, {:disconnect, message}
    end
  end

  setup do
    {:ok, pid} = SampleClient.start_link(%{parent: self()})
    {:ok, client_pid: pid}
  end

  defp pre_connect(pid) do
    options = [client_id: "some-name", host: @mqtt_host, port: @mqtt_port]
    pid |> SampleClient.connect options
  end

  defp post_disconnect(pid) do
    pid |> SampleClient.disconnect
    pid |> SampleClient.stop
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

    pid |> SampleClient.disconnect
    assert_receive {:disconnect, %Message.Disconnect{}}

    pid |> SampleClient.stop
  end

  test "on_publish callback on sending publish", %{client_pid: pid} do
    pre_connect pid

    options = [id: 9_347, topic: "nope", message: "a message",
               dup: 0, qos: 1, retain: 1]
    pid |> SampleClient.publish options
    assert_receive {:publish, %Message.Publish{}}

    post_disconnect pid
  end

  test "on_publish_ack callback on receiving publish_ack", %{client_pid: pid} do
    pre_connect pid

    options = [id: 9_347, topic: "nope", message: "a message",
               dup: 0, qos: 1, retain: 1]
    pid |> SampleClient.publish options
    assert_receive {:publish_ack, %Message.PubAck{}}

    post_disconnect pid
  end

  test "on_publish_receive callback on receiving publish_receive", %{client_pid: pid} do
    pre_connect pid

    options = [id: 9_347, topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    pid |> SampleClient.publish options
    assert_receive {:publish_receive, %Message.PubRec{}}

    post_disconnect pid
  end

  test "on_publish_release callback on sending publish_release", %{client_pid: pid} do
    pre_connect pid

    options = [id: 9_347, topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    pid |> SampleClient.publish options
    assert_receive {:publish_release, %Message.PubRel{}}

    post_disconnect pid
  end

  test "on_publish_complete callback on receiving publish_complete", %{client_pid: pid} do
    pre_connect pid

    options = [id: 9_347, topic: "nope", message: "a message",
               dup: 0, qos: 2, retain: 1]
    pid |> SampleClient.publish options
    assert_receive {:publish_complete, %Message.PubComp{}}

    post_disconnect pid
  end

  test "on_subscribe callback on sending subscribe", %{client_pid: pid} do
    pre_connect pid

    options = [id: 24_756, topics: ["a/b", "c/d"], qoses: [0, 1]]
    pid |> SampleClient.subscribe options
    assert_receive {:subscribe, %Message.Subscribe{}}

    post_disconnect pid
  end

  test "on_subscribe_ack callback on receiving subscribe_ack", %{client_pid: pid} do
    pre_connect pid

    options = [id: 24_756, topics: ["a/b", "c/d"], qoses: [0, 1]]
    pid |> SampleClient.subscribe options
    assert_receive {:subscribe_ack, %Message.SubAck{}}

    post_disconnect pid
  end

  test "on_unsubscribe callback on sending unsubscribe", %{client_pid: pid} do
    pre_connect pid

    options = [id: 12_385, topics: ["a/d", "c/f"]]
    pid |> SampleClient.unsubscribe options
    assert_receive {:unsubscribe, %Message.Unsubscribe{}}

    post_disconnect pid
  end

  test "on_unsubscribe_ack callback on receiving unsubscribe_ack", %{client_pid: pid} do
    pre_connect pid

    options = [id: 12_385, topics: ["a/d", "c/f"]]
    pid |> SampleClient.unsubscribe options
    assert_receive {:unsubscribe_ack, %Message.UnsubAck{}}

    post_disconnect pid
  end

  test "on_ping callback on sending ping", %{client_pid: pid} do
    pre_connect pid

    pid |> SampleClient.ping
    assert_receive {:ping, %Message.PingReq{}}

    post_disconnect pid
  end

  test "on_pong callback on receiving ping_resp", %{client_pid: pid} do
    pre_connect pid

    pid |> SampleClient.ping
    assert_receive {:pong, %Message.PingResp{}}

    post_disconnect pid
  end

  test "on_subscribed_publish callback on receiving publish on subscribed topic", %{client_pid: pid} do
    pre_connect pid

    options = [id: 24_756, topics: ["awesome"], qoses: [0]]
    pid |> SampleClient.subscribe options

    spawn fn ->
      {:ok, pid2} = SampleClient.start_link(%{parent: self})

      options = [client_id: "another-name", host: @mqtt_host, port: @mqtt_port]
      pid2 |> SampleClient.connect options

      options = [id: 11_175, topic: "awesome", message: "a message",
                 dup: 0, qos: 1, retain: 1]
      pid2 |> SampleClient.publish options

      post_disconnect pid2
    end

    assert_receive {:subscribed_publish, %Message.Publish{}}

    post_disconnect pid
  end

end
