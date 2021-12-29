defmodule Niss do
  @moduledoc """
  Niss keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def change_fields_valid?(change, fields) do
    change.valid? || Enum.all?(fields, &(!Keyword.has_key?(change.errors, &1)))
  end

  @spec rpc_primary(module(), fun(), [any()]) :: any()
  def rpc_primary(mod, fun, args) do
    Fly.RPC.rpc_region(Fly.primary_region(), mod, fun, args)
  end

  def rpc_primary(func) do
    if primary?() do
      func.()
    else
      rpc_primary(__MODULE__, :rpc_primary, [func])
    end
  end

  def primary?, do: Fly.is_primary?()

  def titlecase(s) do
    [first | rest] = String.graphemes(s)
    String.upcase(first) <> Enum.join(rest)
  end

  def convert_timezone!(datetime, tz) do
    case Timex.Timezone.convert(datetime, tz) do
      {:error, error} ->
        raise "convert_timezone!(#{inspect(datetime)}, #{inspect(tz)}): #{inspect(error, pretty: true)}"

      datetime ->
        datetime
    end
  end
end
