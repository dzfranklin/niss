defmodule Niss.Now.Impl do
  @behaviour Niss.Now

  @impl true
  def utc_now, do: DateTime.utc_now()

  @impl true
  def now_in!(tz) do
    case Timex.now(tz) do
      {:error, error} -> raise "now_in/1: #{inspect(error)}"
      datetime -> datetime
    end
  end
end
