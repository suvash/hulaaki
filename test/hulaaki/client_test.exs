defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  use GenEvent
  alias Hulaaki.Message

  defmodule TestClient do
    use Hulaaki.Client

    def on_event(event, state) do
      Kernel.send state.parent, event
    end

    def on_connect(event, state) do
      Kernel.send state.parent, event
    end

  end

  setup do
    {:ok, pid} = TestClient.start(%{parent: self()})
    {:ok, client_pid: pid}
  end

  test "client receives GenEvent notifications", %{client_pid: pid} do
    pid |> GenEvent.sync_notify {:amazing, :tuple}

    assert_receive {:amazing, :tuple}
  end

  test "client receives connect_ack notification", %{client_pid: pid} do
    session_present = 0
    return_code = 3
    message = Message.connect_ack(session_present, return_code)

    pid |> GenEvent.sync_notify message

    assert_receive %Hulaaki.Message.ConnAck{return_code: 3, session_present: 0}
  end
end
