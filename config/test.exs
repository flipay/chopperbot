use Mix.Config

config :chopperbot, port: 4001
config :chopperbot, Chopperbot.MessageBuilder, test: Chopperbot.TestMessageBuilder

config :chopperbot, Linex, message: Linex.TestMessage
