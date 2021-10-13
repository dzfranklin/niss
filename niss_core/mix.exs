defmodule NissCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :niss_core,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env())
    ]
  end

  def compiler_paths(:test), do: compiler_paths(:dev) ++ ["test/support"]
  def compiler_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 0.4"}
    ]
  end
end
