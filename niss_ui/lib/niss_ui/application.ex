defmodule NissUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Ecto repository
      NissUi.Repo,
      # Start the Telemetry supervisor
      NissUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NissUi.PubSub},
      # Start the Endpoint (http/https)
      NissUiWeb.Endpoint,
      # Start Cluster
      {Cluster.Supervisor, [topologies, [name: NissUi.ClusterSupervisor]]}
      # Start a worker by calling: NissUi.Worker.start_link(arg)
      # {NissUi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NissUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NissUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
