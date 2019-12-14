use Mix.Config

# This way of interpolating config is for Gigalixir
# ref: https://gigalixir.readthedocs.io/en/latest/main.html#using-environment-variables-in-your-app
config :chopperbot, Linex, channel_access_token: "${LINE_CHANNEL_ACCESS_TOKEN}"
