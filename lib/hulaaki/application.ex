defmodule Hulaaki.Application do
  use Application

  def start(_type, _args) do
    children = [System.version() |> String.slice(0..2) |> connection_supervisor_child_spec()]

    opts = [strategy: :one_for_one, name: Hulaaki.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp connection_supervisor_child_spec("1.4") do
    import Supervisor.Spec, only: [supervisor: 3]

    supervisor(Hulaaki.Connection.Supervisor, [:ok], [])
  end

  defp connection_supervisor_child_spec(_), do: Hulaaki.Connection.Supervisor
end
