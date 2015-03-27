defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  use GenEvent

  defmodule TestClient do
    use Hulaaki.Client

    def on_event(event, state) do
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

end
