defmodule NissWeb.PlantsPage.CalendarComponent do
  use NissWeb, :live_component
  alias Timex.Interval
  alias Niss.Plants
  alias NissWeb.PlantRecordComponent

  @week_start_at :sun

  @impl true
  def update(assigns, socket) do
    tz = assigns.intl.tz

    month = Niss.convert_timezone!(assigns.month, tz)

    from =
      Timex.beginning_of_month(month)
      |> Timex.beginning_of_week(@week_start_at)

    to =
      Timex.end_of_month(month)
      |> Timex.end_of_week(@week_start_at)

    dates =
      Interval.new(from: from, until: to, left_open: false, right_open: false)
      |> Enum.map(&Timex.to_date/1)
      |> Enum.chunk_every(7)

    dates_names =
      Interval.new(
        from: from,
        until: Timex.end_of_week(from, @week_start_at),
        left_open: false,
        right_open: false
      )
      |> Enum.map(&Timex.format!(&1, "{WDshort}"))

    records =
      Plants.list_records(from, to)
      |> Enum.reduce(%{}, fn record, acc ->
        date =
          record.at
          |> Niss.convert_timezone!(tz)
          |> Timex.to_date()

        list = Map.get(acc, date, [])
        Map.put(acc, date, [record | list])
      end)
      |> Map.new(fn {date, list} -> {date, Enum.reverse(list)} end)

    socket =
      socket
      |> assign(
        month: month,
        dates_names: dates_names,
        dates: dates,
        records: records
      )
      |> assign(assigns)

    {:ok, socket}
  end

  defp in_month?(date, month) do
    date.year == month.year && date.month == month.month
  end
end
