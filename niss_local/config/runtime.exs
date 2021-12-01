import Config

config :sentry,
  dsn: System.get_env("NISS_LOCAL_SENTRY_DSN")

config :niss_local, NissLocal.Lights,
  plugs: [
    lime: [
      key: System.fetch_env!("NISS_LOCAL_PLUG_A_KEY")
    ],
    chillies: [
      key: System.fetch_env!("NISS_LOCAL_PLUG_B_KEY")
    ]
  ]
