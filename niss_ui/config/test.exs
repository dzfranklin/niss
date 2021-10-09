import Config

config :niss_ui, :site_encrypt,
  db_folder: "/tmp/niss_site_encrypt_db_test",
  directory_url: {:internal, port: 4002}

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :niss_ui, NissUi.Repo, database: "db_test#{System.get_env("MIX_TEST_PARTITION")}.sqlite"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :niss_ui, NissUiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Mf4Act6aQa0DkTnxZzNQ+LCnetQsAGHmfT6NMsKDdIcbyXVEXn45/zQ/Mb4iN9FO",
  server: false

# In test we don't send emails.
config :niss_ui, NissUi.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
