defmodule Hulaaki.ClientTest do
  use ExUnit.Case, async: true
  alias Hulaaki.Message

  defmodule SampleClient do
    use Hulaaki.Client

    def on_connect(message: message, state: state) do
      Kernel.send(state.parent, {:connect, message})
    end

    def on_connect_ack(message: message, state: state) do
      Kernel.send(state.parent, {:connect_ack, message})
    end

    def on_publish(message: message, state: state) do
      Kernel.send(state.parent, {:publish, message})
    end

    def on_subscribed_publish(message: message, state: state) do
      Kernel.send(state.parent, {:subscribed_publish, message})
    end

    def on_subscribed_publish_ack(message: message, state: state) do
      Kernel.send(state.parent, {:subscribed_publish_ack, message})
    end

    def on_publish_receive(message: message, state: state) do
      Kernel.send(state.parent, {:publish_receive, message})
    end

    def on_publish_release(message: message, state: state) do
      Kernel.send(state.parent, {:publish_release, message})
    end

    def on_publish_complete(message: message, state: state) do
      Kernel.send(state.parent, {:publish_complete, message})
    end

    def on_publish_ack(message: message, state: state) do
      Kernel.send(state.parent, {:publish_ack, message})
    end

    def on_subscribe(message: message, state: state) do
      Kernel.send(state.parent, {:subscribe, message})
    end

    def on_subscribe_ack(message: message, state: state) do
      Kernel.send(state.parent, {:subscribe_ack, message})
    end

    def on_unsubscribe(message: message, state: state) do
      Kernel.send(state.parent, {:unsubscribe, message})
    end

    def on_unsubscribe_ack(message: message, state: state) do
      Kernel.send(state.parent, {:unsubscribe_ack, message})
    end

    def on_ping(message: message, state: state) do
      Kernel.send(state.parent, {:ping, message})
    end

    def on_ping_response(message: message, state: state) do
      Kernel.send(state.parent, {:ping_response, message})
    end

    def on_ping_response_timeout(message: message, state: state) do
      Kernel.send(state.parent, {:ping_response_timeout, message})
    end

    def on_disconnect(message: message, state: state) do
      Kernel.send(state.parent, {:disconnect, message})
    end
  end

  setup do
    {:ok, pid} = SampleClient.start_link(%{parent: self()})
    {:ok, client_pid: pid}
  end

  defp pre_connect(pid) do
    options = [
      client_id: TestHelper.random_name(),
      host: TestConfig.mqtt_host(),
      port: TestConfig.mqtt_port(),
      timeout: TestConfig.mqtt_timeout()
    ]

    :ok = SampleClient.connect(pid, options)
  end

  defp post_disconnect(pid) do
    SampleClient.disconnect(pid)
    SampleClient.stop(pid)
  end

  test "error message when sending message without connecting", %{client_pid: pid} do
    options = [
      client_id: TestHelper.random_name(),
      host: TestConfig.mqtt_host(),
      port: 7878,
      timeout: TestConfig.mqtt_timeout()
    ]

    reply = SampleClient.ping(pid)

    assert {:error, :not_connected} == reply
  end
end
