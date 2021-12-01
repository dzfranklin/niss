import Config

config :sentry,
  dsn: System.get_env("NISS_LOCAL_SENTRY_DSN")

