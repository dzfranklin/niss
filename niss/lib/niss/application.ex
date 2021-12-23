defmodule Niss.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children =
      [
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
        maybe_child(:cluster, {Cluster.Supervisor, [topologies, [name: Niss.ClusterSupervisor]]}),
        maybe_child(:executor, {Niss.Executor, name: {:global, Niss.Executor}}),
        maybe_child(
          :tank_level_monitor,
          {Niss.TankLevelMonitor, name: {:global, Niss.TankLevelMonitor}}
        )
      ]
      |> Enum.filter(&(!is_nil(&1)))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Niss.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_child(name, child) do
    primary? = Fly.is_primary?()

    enabled? =
      Application.get_env(:niss, __MODULE__)
      |> Keyword.get(name, false)
      |> case do
        :primary -> primary?
        true -> true
        false -> false
      end

    if enabled? do
      child
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NissWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
