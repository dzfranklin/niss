defmodule Niss.Plants.Impl do
  @behaviour Niss.Plants
  use Niss.Query
  use ExportPrivate
  require Logger
  alias Timex.{Duration, Timezone}
  alias Ecto.Changeset
  alias Niss.{Now, Repo, Local, Executor}
  alias Niss.Plants.{Plant, WateringRecord, LightingRecord, TankLevelRecord}

  @impl true
  def tank_level(%Plant{id: plant_id}) do
    TankLevelRecord
    |> where([r], r.plant_id == ^plant_id)
    |> order_by(desc: :at)
    |> limit(1)
    |> Repo.one()
  end

  @impl true
  def create_tank_level_record(attrs) do
    TankLevelRecord.changeset(attrs)
    |> Repo.insert()
  end

  @impl true
  def execute!(%LightingRecord{} = record) do
    log_for_record(record)

    record = Repo.preload(record, :plant)
    Local.set_light!(identifier(record.plant), record.on?)
    Repo.insert!(record)
  end

  @impl true
  def execute!(%WateringRecord{} = record) do
    log_for_record(record)

    record = Repo.preload(record, :plant)
    Local.pump_for!(identifier(record.plant), record.duration_secs)
    Repo.insert!(record)
  end

  defp log_for_record(record) do
    Logger.info("Executing #{inspect(record, pretty: true)}")

    now = Now.utc_now()

    delta =
      Timex.diff(record.at, now, :minutes)
      |> abs()

    if delta < 5 do
      Logger.debug("at near now for #{inspect(record, pretty: true)}")
    else
      Logger.warn(
        "at not near now. executing anyway. now: #{inspect(now)}, record: #{inspect(record, pretty: true)}"
      )
    end

    nil
  end

  @impl true
  def scheduled_lighting(%Plant{} = plant) do
    scheduled_lighting_helper(plant, last_scheduled_lighting(plant), false, Now.utc_now())
  end

  defp scheduled_lighting_helper(plant, prev, has_missed?, now) do
    record = scheduled_lighting_after(plant, prev, now)

    if Timex.compare(record.at, now) != -1 do
      # record has not been missed
      if has_missed? do
        # but we have missed at least one, so return the last missed
        prev
      else
        # and we haven't missed any, so return the upcoming
        record
      end
    else
      # record has been missed
      scheduled_lighting_helper(plant, record, true, now)
    end
  end

  defp scheduled_lighting_after(plant, last, now) do
    if is_nil(last) do
      at =
        now
        |> convert_timezone!(plant.timezone)
        |> Timex.beginning_of_day()
        |> Timex.add(Duration.from_time(plant.lights_on))
        |> convert_timezone!("Etc/UTC")

      %{on?: true, at: at}
    else
      if last.on? do
        at =
          last.at
          |> convert_timezone!(plant.timezone)
          |> Timex.add(Duration.from_time(plant.lights_duration))
          |> convert_timezone!("Etc/UTC")

        %{on?: false, at: at}
      else
        at =
          last.at
          |> convert_timezone!(plant.timezone)
          |> Timex.beginning_of_day()
          |> Timex.add(Duration.from_days(1))
          |> Timex.add(Duration.from_time(plant.lights_on))
          |> convert_timezone!("Etc/UTC")

        %{on?: true, at: at}
      end
    end
    |> Enum.into(%{
      plant_id: plant.id,
      scheduled?: true
    })
    |> LightingRecord.changeset()
    |> apply_schedule_action!()
  end

  defp last_scheduled_lighting(plant) do
    LightingRecord
    |> where(plant_id: ^plant.id, scheduled?: true)
    |> get_last(:at)
  end

  @impl true
  def scheduled_watering(%Plant{} = plant) do
    scheduled_watering_helper(plant, last_scheduled_watering(plant), false, Now.utc_now())
  end

  defp scheduled_watering_helper(plant, prev, has_missed?, now) do
    record = scheduled_watering_after(plant, prev, now)

    if Timex.compare(record.at, now) != -1 do
      # record has not been missed
      if has_missed? do
        # but we have missed at least one, so return the last missed
        prev
      else
        # and we haven't missed any, so return the upcoming
        record
      end
    else
      # record has been missed
      scheduled_watering_helper(plant, record, true, now)
    end
  end

  defp scheduled_watering_after(plant, last, now) do
    origin = if is_nil(last), do: now, else: last.at

    at =
      origin
      |> convert_timezone!(plant.timezone)
      |> Timex.beginning_of_day()
      |> Timex.add(Duration.from_days(plant.watering_interval_days))
      |> Timex.add(Duration.from_time(plant.watering_time))
      |> convert_timezone!("Etc/UTC")

    WateringRecord.changeset(%{
      plant_id: plant.id,
      duration_secs: plant.watering_duration_secs,
      scheduled?: true,
      at: at
    })
    |> apply_schedule_action!()
  end

  defp last_scheduled_watering(%Plant{} = plant) do
    WateringRecord
    |> where(plant_id: ^plant.id, scheduled?: true)
    |> get_last(:at)
  end

  defp apply_schedule_action!(change), do: Changeset.apply_action!(change, :schedule)

  @impl true
  def list do
    Repo.all(Plant)
  end

  @impl true
  def get!(id) when is_integer(id), do: Repo.get!(Plant, id)

  @impl true
  def create(attrs) do
    Plant.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, plant} ->
        Executor.load_plant(plant)
        {:ok, plant}

      {:error, plant} ->
        {:error, plant}
    end
  end

  @impl true
  def update(plant, attrs) do
    Plant.changeset(plant, attrs)
    |> Repo.update()
    |> case do
      {:ok, plant} ->
        Executor.load_plant(plant)
        {:ok, plant}

      {:error, plant} ->
        {:error, plant}
    end
  end

  @impl true
  def delete(plant) do
    Executor.maybe_cancel_plant(plant)
    Repo.delete(plant)
  end

  @impl true
  def change(plant, attrs) do
    Plant.changeset(plant, attrs)
  end

  @impl true
  def identifier(plant) do
    plant.identifier
    |> String.to_atom()
  end

  defp convert_timezone!(datetime, tz) do
    case Timezone.convert(datetime, tz) do
      {:error, error} ->
        raise "convert_timezone!(#{inspect(datetime)}, #{inspect(tz)}): #{inspect(error, pretty: true)}"

      datetime ->
        datetime
    end
  end
end
