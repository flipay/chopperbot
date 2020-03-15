use Mix.Config

config :chopperbot, port: 4001
config :chopperbot, Chopperbot.Split.MessageBuilder, test: Chopperbot.Split.TestMessageBuilder
config :chopperbot, Linex, message: Linex.TestMessage
