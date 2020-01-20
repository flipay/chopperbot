defmodule Chopperbot.MoneyFormatter do
  @doc """
  Convert an amount number to a string representation.

  ## Examples
      iex> format(100)
      "100.00 THB"

      iex> format(999.500005)
      "999.50 THB"
  """
  @spec format(integer() | float(), atom() | String.t()) :: String.t()
  def format(amount, currency_code \\ :THB) do
    round(amount * 100)
    |> Money.new(currency_code)
    |> Money.to_string(symbol: false)
    |> Kernel.<>(" #{currency_code}")
  end
end
