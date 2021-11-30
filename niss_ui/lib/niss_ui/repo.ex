defmodule NissUi.Repo do
  use Ecto.Repo,
    otp_app: :niss_ui,
    adapter: Ecto.Adapters.Postgres
end
