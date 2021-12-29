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

priv_dir = :code.priv_dir(:niss_local)
{arch, 0} = System.cmd("arch", [])
arch = String.trim(arch)
bins_dir = Path.join([priv_dir, "bins", arch])
if !File.exists?(bins_dir), do: raise("Missing bins dir for arch #{arch}, expected #{bins_dir}")

config :porcelain,
  driver: Porcelain.Driver.Goon,
  goon_driver_path: Path.join([bins_dir, "goon"])
