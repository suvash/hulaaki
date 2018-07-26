defmodule Hulaaki.Connection.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link([], strategy: :one_for_one, name: __MODULE__)
  end

  def init(_), do: :ok
end
