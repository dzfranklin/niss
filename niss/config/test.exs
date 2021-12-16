import Config

config :niss, Niss.Application,
  cluster: false,
  executor: false,
  tank_level_monitor: false

config :niss, :adapters,
  now: Niss.Now.MockImpl,
  local: Niss.Local.MockImpl,
  plants: Niss.Plants.MockImpl

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :niss, Niss.Repo.Local,
  username: "postgres",
  password: "postgres",
  database: "niss_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :niss, NissWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "L9Fgt71UlUk99rxGpVNhlzthRP//rxvndBm7Ue2gZ/F4bJ0hcRXSFxUmpZ6QcfIt",
  server: false

# In test we don't send emails.
config :niss, Niss.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
