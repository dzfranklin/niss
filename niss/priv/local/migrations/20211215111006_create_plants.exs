defmodule Niss.Repo.Migrations.CreatePlants do
  use Ecto.Migration

  def change do
    create table(:plants) do
      add :identifier, :string, null: false
      add :timezone, :string, null: false
      add :watering_interval_days, :integer, null: false
      add :watering_duration_secs, :integer, null: false
      add :watering_time, :time, null: false
      add :lights_on, :time, null: false
      add :lights_duration, :time, null: false
      add :tank_base_area, :float, null: false
      add :tank_max_depth, :float, null: false

      timestamps()
    end

    create unique_index(:plants, [:identifier])

    create table(:plant_watering_records) do
      add :plant_id, references(:plants), null: false
      add :at, :utc_datetime_usec, null: false
      add :duration_secs, :integer, null: false
      add :scheduled?, :boolean, default: false, null: false

      timestamps()
    end

    create index(:plant_watering_records, [:plant_id])
    create index(:plant_watering_records, [:at])
    create index(:plant_watering_records, [:scheduled?])

    create table(:plant_lighting_records) do
      add :plant_id, references(:plants), null: false
      add :scheduled?, :boolean, default: false, null: false
      add :on?, :boolean, default: false, null: false
      add :at, :utc_datetime_usec, null: false

      timestamps()
    end

    create index(:plant_lighting_records, [:plant_id])
    create index(:plant_lighting_records, [:at])
    create index(:plant_lighting_records, [:scheduled?])

    create table(:plants_tank_level_records) do
      add :plant_id, references(:plants, on_delete: :nothing), null: false
      add :remaining, :float
      add :total, :float, null: false
      add :failed?, :boolean, default: false, null: false
      add :at, :utc_datetime, null: false

      timestamps()
    end

    create index(:plants_tank_level_records, [:plant_id])
    create index(:plants_tank_level_records, [:failed?])
    create index(:plants_tank_level_records, [:at])
  end
end
