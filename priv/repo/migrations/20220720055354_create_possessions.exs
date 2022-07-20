defmodule Niss.Repo.Migrations.CreatePossessions do
  use Ecto.Migration

  def change do
    create table(:possessions) do
      add :name, :text
      add :count, :integer
      add :description, :text

      timestamps()
    end
  end
end
