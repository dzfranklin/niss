defmodule Niss.Plants do
  use Niss.Query
  alias Timex.Duration
  alias Ecto.Changeset
  alias Niss.Repo
  alias Niss.Plants.{Plant, WateringRecord, LightingRecord}

  @doc """
  Calculates when to change the light and what to change it to.

  Returns {datetime, on_or_off}
  """
  @spec next_light_change(Plant.t()) :: {DateTime.t(), bool()}
  def next_light_change(
        %Plant{lights_on: on_time, lights_duration: duration} = plant,
        now \\ DateTime.utc_now()
      ) do
    # TODO: logic is wrong
    on_at =
      now
      |> Timex.beginning_of_day()
      |> Timex.add(Duration.from_time(on_time))

    if Time.compare(on_time, DateTime.to_time(now)) != :gt do
      # Lights should be on
      if last_scheduled_lighting?(plant).status do
        # Light correctly on
        off_at = Timex.add(on_at, Duration.from_time(duration))

        {off_at, false}
      else
        # Light incorrectly off
        {now, true}
      end
    else
      # Lights currently correctly off
      {on_at, true}
    end
  end

  defp last_scheduled_lighting?(plant) do
    LightingRecord
    |> where(plant_id: ^plant.id, scheduled: true)
    |> get_last(:time)
  end

  @doc """
  Calculates when to water the plant next and for how long.

  Returns {datetime, duration_secs}
  """
  @spec next_watering(Plant.t()) :: {DateTime.t(), integer()}
  def next_watering(%Plant{} = plant, now \\ DateTime.utc_now()) do
    last = last_scheduled_watering(plant).start || now

    datetime =
      last
      |> Timex.beginning_of_day()
      |> Timex.add(Duration.from_days(plant.watering_interval_days))
      |> Timex.add(Duration.from_time(plant.watering_time))

    {datetime, plant.watering_duration_secs}
  end

  defp last_scheduled_watering(%Plant{} = plant) do
    WateringRecord
    |> where(plant_id: ^plant.id, scheduled?: true)
    |> get_last(:start)
  end

  @spec list :: [Plant.t()]
  def list do
    Repo.all(Plant)
  end

  @spec get!(Plant.id()) :: Plant.t()
  def get!(id), do: Repo.get!(Plant, id)

  @spec create(map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  def create(attrs \\ %{}) do
    %Plant{}
    |> Plant.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(Plant.t(), map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  def update(%Plant{} = plant, attrs) do
    plant
    |> Plant.changeset(attrs)
    |> Repo.update()
  end

  @spec delete(map()) :: {:ok, Plant.t()} | {:error, Changeset.t()}
  def delete(%Plant{} = plant) do
    Repo.delete(plant)
  end

  @spec change(Plant.t(), map()) :: Changeset.t()
  def change(%Plant{} = plant, attrs \\ %{}) do
    Plant.changeset(plant, attrs)
  end
end
