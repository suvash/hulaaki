defmodule Hulaaki.ConnectionTest do
  use ExUnit.Case, async: true
  alias Hulaaki.Connection
  alias Hulaaki.Message

  defmodule SampleTransport do
    @behaviour Hulaaki.Transport
    def connect(_host, _port, _opts, _timeout), do: {:ok, :socket}

    def send(_socket, _packet), do: {:error, :send}

    def close(_socket), do: :ok

    def set_active_once(_socket), do: :ok

    def packet_message, do: :sample
    def closing_message, do: :sample_closed
  end

  setup do
    {:ok, pid} = Connection.start(self())
    {:ok, connection_pid: pid}
  end

  defp pre_connect(pid) do
    message = Message.connect(TestHelper.random_name(), "", "", "", "", 0, 0, 0, 100)

    {:error, :send} =
      Connection.connect(
        pid,
        message,
        host: TestConfig.mqtt_host(),
        port: TestConfig.mqtt_port(),
        timeout: TestConfig.mqtt_timeout(),
        transport: SampleTransport
      )
  end

  defp post_disconnect(pid) do
    Connection.disconnect(pid)
    Connection.stop(pid)
  end

  test "any call in non-connected connection returns error", %{connection_pid: pid} do
    message = Message.publish(1, "", "", 0, 1, 0)

    reply =
      Connection.publish(
        pid,
        message
      )

    assert {:error, :not_connected} == reply
    post_disconnect(pid)
  end

  test "publish in disconnected connection returns error", %{connection_pid: pid} do
    pre_connect(pid)
    message = Message.publish(1, "", "", 0, 1, 0)

    reply =
      Connection.publish(
        pid,
        message
      )

    assert {:error, :send} == reply
    post_disconnect(pid)
  end

  test "subscribe in disconnected connection returns error", %{connection_pid: pid} do
    pre_connect(pid)
    message = Message.subscribe(1, [""], [0])

    reply =
      Connection.subscribe(
        pid,
        message
      )

    assert {:error, :send} == reply
    post_disconnect(pid)
  end

  test "unsubscribe in disconnected connection returns error", %{connection_pid: pid} do
    pre_connect(pid)
    message = Message.unsubscribe(1, [""])

    reply =
      Connection.unsubscribe(
        pid,
        message
      )

    assert {:error, :send} == reply
    post_disconnect(pid)
  end

  test "ping in disconnected connection returns error", %{connection_pid: pid} do
    pre_connect(pid)
    message = Message.ping_request()

    reply =
      Connection.ping(
        pid,
        message
      )

    assert {:error, :send} == reply
    post_disconnect(pid)
  end

  test "disconnect in disconnected connection returns error", %{connection_pid: pid} do
    pre_connect(pid)
    message = Message.disconnect()

    reply =
      Connection.disconnect(
        pid,
        message
      )

    assert {:error, :send} == reply
    post_disconnect(pid)
  end
end
