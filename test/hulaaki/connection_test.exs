defmodule Hulaaki.ConnectionTest do
  use ExUnit.Case
  alias Hulaaki.Connection
  alias Hulaaki.Message

  # defp client_name do
  #   adjectives = [ "lazy", "funny", "bright", "boring", "crazy", "lonely" ]
  #   nouns = [ "thermometer", "switch", "scale", "bulb", "heater", "microwave" ]

  #   :random.seed(:os.timestamp)
  #   [adjective] = adjectives |> Enum.shuffle |> Enum.take 1
  #   [noun] = nouns |> Enum.shuffle |> Enum.take 1

  #   adjective <> "-" <> noun
  # end


  setup do
    {:ok, pid} = Connection.start_link(self)
    {:ok, client_pid: pid}
  end

  test "connects to server gets back a connack", %{client_pid: pid} do
    Connection.connect(pid)

    assert_receive %Message.ConnAck{return_code: 0,
                                    session_present: 1,
                                    type: :CONNACK}

    Connection.stop(pid)
  end

end
