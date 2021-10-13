import Config
require Logger

config :logger, level: :debug
if Mix.env() == :test, do: config(:logger, level: :warn)

if Mix.env() != :dev && Mix.env() != :test, do: raise("niss_core is a library")
if Mix.env() == :dev, do: Logger.warn("niss_core is a library")

config :niss_core, mock?: true
