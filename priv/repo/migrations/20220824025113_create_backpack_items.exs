defmodule Niss.Repo.Migrations.CreateBackpackItems do
  use Ecto.Migration

  def change do
    create table(:backpack_items) do
      add :name, :text
      add :weight, :integer
      add :note, :text
      add :issue, :text

      timestamps()
    end
  end
end
