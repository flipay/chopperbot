defmodule Chopperbot.Split do
  @moduledoc """

  TODO:
  [ ] Add share orders
  [ ] Add vat / service
  [ ] add flexible discount ex. -10%
  """
  @spec run(String.t()) :: String.t()
  def run(text) do
    text
    |> process_input()
    |> calculate_total()
    |> format_string()
  end

  def format_string(list_total) do
    list_total
    |> Enum.map(fn {name, amount} -> "#{name} #{amount}" end)
    |> Enum.join("\n")
  end

  def calculate_total(%{orders: orders, options: _options} = _parsed_input) do
    sum_orders =
      orders
      |> Enum.group_by(fn {name, _amount} -> name end)
      |> Enum.map(fn {name, list} ->
        {
          name,
          list
          |> Enum.map(fn {_name, amount} -> amount end)
          |> Enum.sum()
        }
      end)

    total =
      sum_orders
      |> Enum.map(fn {_name, amount} -> amount end)
      |> Enum.sum()

    sum_orders ++ [{"_total", total}]
  end

  @spec process_input(String.t()) :: map()
  def process_input(text) do
    %{
      orders: parse_orders(text),
      options: parse_options(text)
    }
  end

  @spec parse_options(String.t()) :: list()
  def parse_options(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn s -> option?(s) end)
  end

  @spec parse_orders(String.t()) :: [...]
  def parse_orders(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn s -> not option?(s) and s != "" end)
    |> Enum.chunk_every(2)
    |> Enum.map(fn
      [name, amount] ->
        {float_amount, ""} = Float.parse(amount)
        {name, float_amount}
    end)
  end

  defp option?(string), do: String.match?(string, ~r/^[+-]/)
end
