import Config

config :sentry,
  environment_name: config_env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

config :niss_local, NissLocal.Lights,
  plugs: [
    lime: [
      label: "A",
      ip: "192.168.1.8",
      id: "eb5d7cdb50931846682f2q"
    ],
    chillies: [
      label: "B",
      ip: "192.168.1.9",
      id: "eb83d0090f803ebfbcgtci"
    ]
  ]

import_config "#{config_env()}.exs"
