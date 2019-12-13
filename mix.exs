defmodule Chopperbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :chopperbot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Chopperbot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
