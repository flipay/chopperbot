defmodule Chopperbot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Chopperbot.Worker.start_link(arg)
      {Chopperbot.Worker.HealthCheckWorker, nil},
      {Plug.Cowboy, scheme: :http, plug: Chopperbot.Router, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chopperbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
