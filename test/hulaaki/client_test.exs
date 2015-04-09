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
    options = [client_id: "some-name"]
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

end
