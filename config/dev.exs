use Mix.Config

config :chopperbot, Linex, channel_access_token: System.get_env("LINE_CHANNEL_ACCESS_TOKEN")

config :appsignal, :config, active: false
