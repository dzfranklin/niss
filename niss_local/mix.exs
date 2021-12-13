defmodule NissLocal.MixProject do
  use Mix.Project

  def project do
    [
      app: :niss_local,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NissLocal.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 0.4"},
      {:libcluster, "~> 3.3"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:sentry, "~> 8.0"},
      {:jason, "~> 1.1"},
      {:hackney, "~> 1.8"},
      {:systemd, "~> 0.6"}
    ]
  end

  defp releases do
    [
      niss_local: [
        include_executables_for: [:unix],
        # See <https://fly.io/docs/app-guides/elixir-static-cookie/>
        # Generate with `Base.url_encode64(:crypto.strong_rand_bytes(40))`
        cookie: System.get_env("NISS_COOKIE", "DUMMY_COOKIE")
      ]
    ]
  end
end
