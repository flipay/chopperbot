defmodule Chopperbot.Split do
  alias Chopperbot.Split.{MessageBuilder, OrderCalculator, Parser}

  # @doc """
  # Process text input for /split to result
  #
  # ## Examples
  #     iex> run("a 100 a 200 b 300 +v +s")
  #     {:ok, [{"a", 353.1}, {"b", 353.1}, {"_total", 706.2}]}
  #
  #     iex> run("a 1100 b 300 share 200 +s")
  #     {:ok, [{"a", 1320.0}, {"b", 440.00000000000006}, {"_total", 1760.0}]}
  #
  #     iex> run("a 1100 b 300 share 200 +invalid -haha")
  #     {:error, "invalid options: +invalid, -haha"}
  #
  #     iex> run("a 1100 b 300 share five dollars")
  #     {:error, "invalid inputs: five, dollars"}
  # """
  # @spec run(String.t()) :: {:ok, [Order.t()]} | {:error, String.t()}
  # def run(text) do
  #   case Parser.parse(text) do
  #     {:ok, %{orders: orders, multiplier: multiplier}} ->
  #       calculated_orders = OrderCalculator.calculate(orders, multiplier)
  #       {:ok, calculated_orders}
  #
  #     {:error, :invalid_option, invalid_options} ->
  #       error_text = "invalid options: " <> Enum.join(invalid_options, ", ")
  #       {:error, error_text}
  #
  #     {:error, :invalid_input, invalid_inputs} ->
  #       error_text = "invalid inputs: " <> Enum.join(invalid_inputs, ", ")
  #       {:error, error_text}
  #   end
  # end

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
