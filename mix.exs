defmodule Chopperbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :chopperbot,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_core_path: "_build/#{Mix.env()}"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Chopperbot.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:money, "~> 1.4"},
      {:httpoison, "~> 1.6"},
      {:mox, "~> 0.5", only: :test},
      {:bypass, "~> 1.0", only: :test},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:appsignal, "~> 1.0"}
    ]
  end
end
