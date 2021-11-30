import Config

config :sentry,
  dsn: System.fetch_env!("NISS_LOCAL_SENTRY_DSN"),
  environment_name: config_env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

import_config "#{config_env()}.exs"
