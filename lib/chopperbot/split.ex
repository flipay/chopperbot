defmodule Chopperbot.Split do
  @moduledoc """

  TODO:
  [ ] Make share order more intuitive ex. a 100 b 200 share 500
  [ ] add flexible discount ex. -10%
  """
  @spec run(String.t()) :: String.t()
  def run(text) do
    text
    |> process_input()
    |> calculate_total()
    |> format_string()
    |> add_character_talk()
  end

  def format_string(list_total) do
    list_total
    |> Enum.map(fn
      {"_total", amount} -> "*total: #{amount} THB*"
      {name, amount} -> "#{name}: #{amount} THB"
    end)
    |> Enum.join("\n")
  end

  @doc """
  Make the bot cuter with the actual quote of Chopper
  ref: https://koei.fandom.com/wiki/Tony_Tony_Chopper/Quotes
  """
  def add_character_talk(text) do
    talk =
      Enum.random([
        "Wowww! I'm rocking this!",
        "All right! I got 'em!",
        "This is this power I've got!",
        "I want to be the sort of man people can rely on!",
        "I gotta give my all for everyone in my crew!",
        "Hey! I did it!",
        "I will be even more dependable!",
        "I am a brash... monster!",
        "Wowowow!!! I'm so strooong!"
      ])

    "#{talk}\n\n#{text}"
  end

  @spec apply_options(list(), list()) :: list()
  def apply_options(orders, ["+service" | rest]), do: apply_options(orders, ["+s" | rest])
  def apply_options(orders, ["+vat" | rest]), do: apply_options(orders, ["+v" | rest])

  def apply_options(orders, ["+s" | rest]) do
    apply_options(
      Enum.map(orders, fn {name, amount} -> {name, rounding_floating_problem(amount * 1.10)} end),
      rest
    )
  end

  def apply_options(orders, ["+v" | rest]) do
    apply_options(
      Enum.map(orders, fn {name, amount} -> {name, rounding_floating_problem(amount * 1.07)} end),
      rest
    )
  end

  def apply_options(orders, [opt | rest]) do
    new_orders =
      cond do
        # split share amount in "+share1000" to all orders
        String.starts_with?(opt, "+share") ->
          ["", amount] = String.split(opt, "+share")
          {float_amount, ""} = Float.parse(amount)
          share_portion = float_amount / length(orders)

          Enum.map(orders, fn {name, amount} ->
            {name, rounding_floating_problem(amount + share_portion)}
          end)
      end

    apply_options(new_orders, rest)
  end

  def apply_options(orders, []), do: orders

  # FIXME: use the proper way to handle the float precision
  defp rounding_floating_problem(float), do: round(float * 100) / 100

  def calculate_total(%{orders: orders, options: options} = _parsed_input) do
    sum_orders =
      orders
      |> Enum.group_by(fn {name, _amount} -> name end)
      |> Enum.map(fn {name, orders} -> {name, sum_amount(orders)} end)
      |> apply_options(options)

    sum_orders ++ [{"_total", sum_amount(sum_orders)}]
  end

  defp sum_amount(orders) do
    orders
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
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
