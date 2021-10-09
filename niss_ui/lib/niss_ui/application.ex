defmodule NissUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    ensure_db_setup!()

    children = [
      # Start the Ecto repository
      NissUi.Repo,
      # Start the Telemetry supervisor
      NissUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NissUi.PubSub},
      # Start the Endpoint (http/https)
      NissUiWeb.Endpoint
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

  defp ensure_db_setup! do
    ensure_repo_setup!(NissUi.Repo)
    ensure_repo_migrated!(NissUi.Repo)
  end

  defp ensure_repo_setup!(repo) do
    db_file = Application.get_env(:niss_ui, repo)[:database]

    unless File.exists?(db_file) do
      :ok = repo.__adapter__.storage_up(repo.config)
    end
  end

  defp ensure_repo_migrated!(repo) do
    Ecto.Migrator.with_repo(
      repo,
      &Ecto.Migrator.run(&1, :up, all: true)
    )
  end
end
