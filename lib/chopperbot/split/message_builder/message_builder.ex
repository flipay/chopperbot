defmodule Chopperbot.Split.MessageBuilder do
  alias Chopperbot.Split.CalculatedOrdersResult

  defmacro __using__(_) do
    quote do
      @behaviour Chopperbot.Split.MessageBuilder

      alias Chopperbot.{
        Character,
        MoneyFormatter
      }

      alias Chopperbot.Split.CalculatedOrdersResult
    end
  end

  @callback build_ok_message(CalculatedOrdersResult.t()) :: map()
  @callback build_error_message(String.t()) :: map()

  @spec from_platform(atom()) :: module()
  def from_platform(platform) do
    :chopperbot
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(platform)
  end
end
