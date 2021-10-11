defmodule NissUi.Repo.Migrations.CreateAuthTokens do
  use Ecto.Migration

  def change do
    create table(:auth_tokens) do
      add :token, :binary
      add :created_by_ip, :text

      timestamps()
    end
  end
end
