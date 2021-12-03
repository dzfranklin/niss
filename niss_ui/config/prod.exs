import Config

# Do not print debug messages in production
config :logger, level: :info

# Remember endpoint also configured in config/runtime.exs

config :niss_ui, NissUiWeb.Endpoint,
  url: [host: "niss.danielzfranklin.org", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto], host: nil],
  cache_static_manifest: "priv/static/cache_manifest.json"
