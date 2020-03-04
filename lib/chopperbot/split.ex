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

      {:error, :invalid_input, invalid_inputs} ->
        error_text = "invalid inputs: " <> Enum.join(invalid_inputs, ", ")
        message_builder.build_error_message(error_text)

      {:error, :invalid_option, invalid_options} ->
        error_text = "invalid options: " <> Enum.join(invalid_options, ", ")
        message_builder.build_error_message(error_text)
    end
  end
end
