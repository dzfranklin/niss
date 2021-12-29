defmodule NissWeb.TimeComponent do
  use NissWeb, :component

  @doc """
  Params:
  - `duration`: `Time` | `Timex.Duration`
  - `class`: `String`
  """
  def duration(assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <span class={@class}><%= format_duration(@duration) %></span>
    """
  end

  @doc """
  Params:
  - `datetime`: `DateTime`
  - `tz`: `String`
  - `class`: `String`
  """
  def datetime(assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <span class={@class}><%= format_datetime(@datetime, @tz) %></span>
    """
  end

  @doc """
  Params:
  - `datetime`: `DateTime`
  - `primary_tz`: `String`
  - `alternate_tz`: `String`
  - `class`: `String`
  """
  def datetime_with_alternate(assigns) do
    assigns = Map.put_new(assigns, :class, "")

    ~H"""
    <span class={@class}
      title={"#{format_datetime(@datetime, @alternate_tz)} in #{@alternate_tz}"}
    ><%= format_datetime(@datetime, @primary_tz) %></span>
    """
  end

  @doc """
  Params:
  - `time`: `Time`/`DateTime`
  - `store_tz`: `String`, required if `time` is a `Time`
  - `tz`: `String`
  - `class`: `String`
  """
  def time(assigns) do
    assigns =
      assigns
      |> Map.put_new(:store_tz, "")
      |> Map.put_new(:class, "")

    ~H"""
    <span class={@class}><%= format_time(@time, @store_tz, @tz) %></span>
    """
  end

  @doc """
  Params:
  - `time`: `Time`/`DateTime`
  - `store_tz`: `String`, required if `time` is a `Time`
  - `primary_tz`: `String`
  - `alternate_tz`: `String`
  - `class`: `String`
  """
  def time_with_alternate(assigns) do
    assigns =
      assigns
      |> Map.put_new(:store_tz, "")
      |> Map.put_new(:class, "")

    ~H"""
    <span class={@class}
      title={"#{format_time(@time, @store_tz, @alternate_tz)} in #{@alternate_tz}"}
    ><%= format_time(@time, @store_tz, @primary_tz) %></span>
    """
  end

  defp format_time(%Time{} = time, store_tz, display_tz) do
    DateTime.new!(Date.utc_today(), time, store_tz)
    |> format_time(store_tz, display_tz)
  end

  defp format_time(time, _store_tz, display_tz) do
    time
    |> Niss.convert_timezone!(display_tz)
    |> Timex.format!("{h12}:{m}{am}")
  end

  defp format_datetime(datetime, tz) do
    datetime
    |> Niss.convert_timezone!(tz)
    |> Timex.format!("{WDshort} {YYYY}-{M}-{D} {h12}:{m}{am}")
  end

  defp format_duration(%Time{} = time) do
    Timex.Duration.from_time(time)
    |> format_duration()
  end

  defp format_duration(duration) do
    IO.inspect(duration)
    Timex.format_duration(duration, :humanized)
  end
end
