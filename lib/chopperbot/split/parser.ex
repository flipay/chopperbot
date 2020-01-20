defmodule Chopperbot.Split.Parser do
  alias Chopperbot.Split.{
    InputTransformer,
    OptionTransformer,
    Order
  }

  @white_space_pattern ~r/\p{Zs}/u

  @doc """
  Parse text into the correct orders & multiplier.

  ## Examples
      iex> parse("a 100 a 200 b 300 +v +s")
      {:ok, %{orders: [{"a", 100.0}, {"a", 200.0}, {"b", 300.0}], multiplier: 1.177}}

      iex> parse("a 100 b 300 -50%")
      {:ok, %{orders: [{"a", 100.0}, {"b", 300.0}], multiplier: 0.5}}

      iex> parse("a 100 b 300 +t +invalid")
      {:error, :invalid_option, ["+t", "+invalid"]}

      iex> parse("a one-hundred b ten baht +v +s")
      {:error, :invalid_input, ["one-hundred", "ten", "baht"]}
  """
  @spec parse(String.t()) ::
          {:ok, %{orders: [Order.t()], multiplier: float()}}
          | {:error, :invalid_option, [String.t()]}
          | {:error, :invalid_input, [String.t()]}
  def parse(text) do
    {options, inputs} =
      text
      |> String.split(@white_space_pattern, trim: true)
      |> Enum.split_with(&option?/1)

    with {:ok, multiplier} <- OptionTransformer.transform(options),
         {:ok, orders} <- InputTransformer.transform(inputs) do
      {:ok, %{orders: orders, multiplier: multiplier}}
    end
  end

  defp option?(string) do
    not number?(string) and String.match?(string, ~r/^[+-]/)
  end

  defp number?(string) do
    case Float.parse(string) do
      {_, ""} -> true
      _ -> false
    end
  end
end
