use Mix.Config

config :appsignal, :config, active: false

config :chopperbot, Linex,
  channel_access_token: System.get_env("LINE_CHANNEL_ACCESS_TOKEN"),
  message: Linex.Message
