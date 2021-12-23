defmodule Niss.TankLevelMonitor do
  use GenServer
  use ExportPrivate
  require Logger
  alias Timex.Duration
  alias Niss.{Plants, Now, Local}

  @type serv :: GenServer.server()

  @default_interval Duration.from_hours(1)

  # Public api

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  # Internal
  @impl true
  def init(opts) do
    state = %{interval: Keyword.get(opts, :interval, @default_interval)}
    _schedule_next_check(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:do_scheduled, state) do
    Plants.list()
    |> Enum.each(fn plant -> _get_and_record(plant) end)

    _schedule_next_check(state)

    {:noreply, state}
  end

  defp _get_and_record(plant) do
    case _get_remaining(plant) do
      {:ok, remaining} ->
        %{
          failed?: false,
          remaining: remaining
        }

      {:error, _error} ->
        %{
          failed?: true,
          remaining: nil
        }
    end
    |> Enum.into(%{
      plant_id: plant.id,
      total: meters_deep_to_liters(plant, plant.tank_max_depth),
      at: Now.utc_now()
    })
    |> save_record!()
  end

  defp meters_deep_to_liters(plant, depth) do
    cubic_meters = plant.tank_base_area * depth
    cubic_meters * 1_000
  end

  defp save_record!(attrs) do
    {:ok, _record} = Plants.create_tank_level_record(attrs)
    nil
  end

  defp _get_remaining(plant) do
    with {:ok, levels} <- _get_levels(plant),
         {:ok, highest_cm} <- _calc_highest_level(levels) do
      highest_m = highest_cm / 100
      {:ok, meters_deep_to_liters(plant, highest_m)}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp _calc_highest_level(levels) do
    Enum.reduce_while(levels, {0, false}, fn {new, at?}, {highest, done?} ->
      if at? do
        if done? do
          Logger.warn("calc_highest_level: inconsistent reading: #{inspect(levels)}")
          {:halt, {:error, :inconsistent}}
        else
          {:cont, {new, false}}
        end
      else
        {:cont, {highest, true}}
      end
    end)
    |> case do
      {:error, error} -> {:error, error}
      {highest, _done?} -> {:ok, highest}
    end
  end

  defp _get_levels(plant) do
    ident = String.to_atom(plant.identifier)

    try do
      {:ok, Local.water_levels!(ident)}
    rescue
      error ->
        Logger.warn("get_levels/1: #{inspect(error)}")
        {:error, error}
    catch
      error ->
        Logger.warn("get_levels/1: #{inspect(error)}")
        {:error, error}
    end
  end

  defp _schedule_next_check(state) do
    millis = state.interval |> Duration.to_milliseconds() |> round()
    Process.send_after(self(), :do_scheduled, millis)
    nil
  end
end
