defmodule Niss.Repo.Migrations.CreatePossessionImages do
  use Ecto.Migration

  def change do
    create table(:possession_images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      timestamps()
    end

    alter table(:possessions) do
      add :image_id, references(:possession_images, type: :binary_id)
    end
  end
end
