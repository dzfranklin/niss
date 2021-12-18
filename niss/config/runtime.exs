import Config

if config_env() != :prod do
  # Fake these so Fly.Postgres doesn't complain
  System.put_env("PRIMARY_REGION", "xyz")
  System.put_env("FLY_REGION", "xyz")
end

auth_pass = System.get_env("NISS_AUTH_PASS")

auth_pass =
  if is_nil(auth_pass) do
    if config_env() == :prod do
      raise "Missing env var NISS_AUTH_PASS"
    else
      "dummy_pass"
    end
  else
    auth_pass
  end

config :niss, Niss.Auth, pass: auth_pass

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  app_name = System.get_env("FLY_APP_NAME") || raise "FLY_APP_NAME not available"

  config :niss, Niss.Repo.Local,
    socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    show_sensitive_data_on_connection_error: true,
    ssl: false

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # Remember endpoint also configured in config/prod.exs

  config :niss, NissWeb.Endpoint,
    server: true,
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # Configure clustering

  config :libcluster,
    debug: true,
    topologies: [
      fly6pn: [
        strategy: Cluster.Strategy.DNSPoll,
        config: [
          polling_interval: 5_000,
          query: "#{app_name}.internal",
          node_basename: app_name
        ]
      ],
      local: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [:"niss_local@niss-local._peer.internal"]
        ]
      ]
    ]

  twilio_token = System.fetch_env!("TWILIO_TOKEN")

  config :twilio_signature_plug,
    auth_token: twilio_token

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :niss, Niss.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
