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
  @local_repo Niss.Repo.Local
  use Fly.Repo, local_repo: @local_repo

  def query(sql, params \\ [], opts \\ []) do
    Niss.rpc_primary(fn ->
      Ecto.Adapters.SQL.query(@local_repo, sql, params, opts)
    end)
  end

  def query!(sql, params \\ [], opts \\ []) do
    Niss.rpc_primary(fn ->
      Ecto.Adapters.SQL.query!(@local_repo, sql, params, opts)
    end)
  end

  def load_into(%Postgrex.Result{columns: cols, rows: rows}, schema) do
    Enum.map(rows, &@local_repo.load(schema, {cols, &1}))
  end

  def load_into({:error, error}, _schema), do: {:error, error}

  def load_into({:ok, %Postgrex.Result{columns: cols, rows: rows}}, schema) do
    values = Enum.map(rows, &@local_repo.load(schema, {cols, &1}))
    {:ok, values}
  end
end
