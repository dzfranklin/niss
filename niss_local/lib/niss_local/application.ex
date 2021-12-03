defmodule NissLocal.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

    children = []

    opts = [strategy: :one_for_one, name: NissLocal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
