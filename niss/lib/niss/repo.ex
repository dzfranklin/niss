defmodule Niss.Repo.Local do
  use Ecto.Repo,
    otp_app: :niss,
    adapter: Ecto.Adapters.Postgres

  # Dynamically configure the database url based on runtime environment.
  def init(_type, config) do
    {:ok, Keyword.put(config, :url, Fly.Postgres.database_url())}
  end
end

defmodule Niss.Repo do
  use Fly.Repo, local_repo: Niss.Repo.Local
end
