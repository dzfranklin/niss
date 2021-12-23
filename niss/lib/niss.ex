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

  def rpc_primary(mod, fun, args) do
    Fly.RPC.rpc_region(Fly.primary_region(), mod, fun, args)
  end
end
