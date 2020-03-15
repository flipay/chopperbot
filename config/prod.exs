use Mix.Config

config :chopperbot, url: System.get_env("APP_URL")

config :chopperbot, Chopperbot.Worker.HealthCheckWorker,
  worker_interval_ms: 600_000,
  enabled: true

config :appsignal, :config, active: true

config :chopperbot, Linex,
  channel_access_token: System.get_env("LINE_CHANNEL_ACCESS_TOKEN"),
  message: Linex.Message
