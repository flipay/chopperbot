defmodule Chopperbot.Split do
  alias Chopperbot.Split.{MessageBuilder, OrderCalculator, Parser}

  @spec process(String.t(), for: atom()) :: map()
  def process(text, for: platform) do
    message_builder = MessageBuilder.from_platform(platform)

    case Parser.parse(text) do
      {:ok, %{orders: orders, multiplier: multiplier}} ->
        orders
        |> OrderCalculator.calculate(multiplier)
        |> message_builder.build_ok_message()

      {:error, error_text} ->
        message_builder.build_error_message(error_text)
    end
  end
end
