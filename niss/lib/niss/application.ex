defmodule Niss.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Used by Fly.Postgres
      {Fly.RPC, []},
      Niss.Repo.Local,
      # Start the tracker after your DB.
      {Fly.Postgres.LSN.Tracker, []},
      # Start the Telemetry supervisor
      NissWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Niss.PubSub},
      # Start the Endpoint (http/https)
      NissWeb.Endpoint,
      # Start Cluster
      {Cluster.Supervisor, [topologies, [name: Niss.ClusterSupervisor]]}
      # Start a worker by calling: Niss.Worker.start_link(arg)
      # {Niss.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Niss.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NissWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
