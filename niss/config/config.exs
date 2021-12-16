# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fly_postgres,
  local_repo: Niss.Repo.Local

config :niss, :adapters,
  now: Niss.Now.Impl,
  local: Niss.Local.Impl,
  plants: Niss.Plants.Impl

config :niss, Niss.Local.Impl, local_node: :"niss_local@niss-local._peer.internal"

config :niss,
  ecto_repos: [Niss.Repo.Local]

# Configures the endpoint
config :niss, NissWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NissWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Niss.PubSub,
  live_view: [signing_salt: "CxGA0whq"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :niss, Niss.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
