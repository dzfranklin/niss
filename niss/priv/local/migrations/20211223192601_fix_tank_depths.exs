defmodule Niss.Repo.Local.Migrations.FixTankDepths do
  use Ecto.Migration

  def change do
    execute """
      UPDATE plants_tank_level_records
      SET remaining = remaining / 100;
    """
  end
end
