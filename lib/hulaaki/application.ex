defmodule Hulaaki.Application do
  use Application

  def start(_type, _args) do
    children = [{DynamicSupervisor, strategy: :one_for_one, name: Hulaaki.Connection.Supervisor}]
    opts = [strategy: :one_for_one, name: Hulaaki.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
