defmodule Niss.Repo do
  use Ecto.Repo,
    otp_app: :niss,
    adapter: Ecto.Adapters.Postgres
end
