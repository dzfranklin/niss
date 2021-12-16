defmodule Niss.Now do
  @adapter Application.fetch_env!(:niss, :adapters)[:now]

  @callback utc_now :: DateTime.t()
  defdelegate utc_now, to: @adapter

  @callback now_in!(String.t()) :: DateTime.t()
  defdelegate now_in!(timezone), to: @adapter
end
