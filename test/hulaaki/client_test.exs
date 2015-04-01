defmodule Hulaaki.ClientTest do
  use ExUnit.Case
  use GenEvent
  alias Hulaaki.Message

  defmodule SampleClient do
    use Hulaaki.Client

    def on_connect(event, state) do
      Kernel.send state.parent, event
    end

  end

  setup do
    {:ok, pid} = SampleClient.start(%{parent: self()})
    {:ok, client_pid: pid}
  end

  test "on_connect callback on receiving connect_ack", %{client_pid: pid} do
    options = [client_id: "some-name"]

    pid |> SampleClient.connect options

    assert_receive %Hulaaki.Message.ConnAck{return_code: 0, session_present: 0}
  end
end
