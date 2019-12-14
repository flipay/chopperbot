defmodule Chopperbot.Split do
  @moduledoc """

  TODO:
  [ ] Make share order more intuitive ex. a 100 b 200 share 500
  [ ] add flexible discount ex. -10%
  [ ] [Bug] String.split wrong on copy & paste the command in Slack
  """

  @doc """
  Process text input for /split to result

  ## Examples
      iex> run("a 100 a 200 b 300 +v +s")
      "a: 353.1 THB\\nb: 353.1 THB\\n*total: 706.2 THB*"
  """
  @spec run(String.t()) :: String.t()
  def run(text) do
    text
    |> process_input()
    |> calculate_orders()
    |> add_total()
    |> format_slack_string()
  end

  @doc """
  Convert the list of calculated order to slack-compatible string

  ## Examples
      iex> format_slack_string([{"a", 300}, {"b", 400}, {"c", 300}, {"_total", 1000}])
      "a: 300 THB\\nb: 400 THB\\nc: 300 THB\\n*total: 1000 THB*"
  """
  def format_slack_string(list_total) do
    list_total
    |> Enum.map(fn
      {"_total", amount} -> "*total: #{amount} THB*"
      {name, amount} -> "#{name}: #{amount} THB"
    end)
    |> Enum.join("\n")
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

  @doc """
  group and sum the order with the same name from process_input

  ## Examples
      iex> calculate_orders(%{orders: [{"a", 100}, {"a", 200}, {"b", 300}, {"c", 400}], options: []})
      [{"a", 300}, {"b", 300}, {"c", 400}]
      iex> calculate_orders(%{orders: [{"a", 100}, {"b", 300}], options: ["+s"]})
      [{"a", 110.0}, {"b", 330.0}]
  """
  @spec calculate_orders(%{options: [binary], orders: [...]}) :: [...]
  def calculate_orders(%{orders: orders, options: options} = _parsed_input) do
    sum_orders =
      orders
      |> Enum.group_by(fn {name, _amount} -> name end)
      |> Enum.map(fn {name, orders} -> {name, sum_orders_amount(orders)} end)
      |> apply_options(options)

    sum_orders
  end

  @doc """
  add _total amount to order

  ## Examples
      iex> add_total([{"a", 300}, {"b", 300}, {"c", 400}])
      [{"a", 300}, {"b", 300}, {"c", 400}, {"_total", 1000}]
  """
  def add_total(orders) do
    orders ++ [{"_total", sum_orders_amount(orders)}]
  end

  defp sum_orders_amount(orders) do
    orders
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
  end

  @doc """
  process text into the correct orders & options

  ## Examples
      iex> process_input("a 100 a 200 b 300 +v +s")
      %{orders: [{"a", 100.0}, {"a", 200.0}, {"b", 300.0}], options: ["+v", "+s"]}
  """
  @spec process_input(String.t()) :: map()
  def process_input(text) do
    %{
      orders: parse_orders(text),
      options: parse_options(text)
    }
  end

  @doc """
  Extract options out of the text into the list

  ## Example
      iex> parse_orders("turbo 10 kendo 200 +v +s")
      [{"turbo", 10.0}, {"kendo", 200.0}]
      iex> parse_orders("neo 310 -5%")
      [{"neo", 310.0}]
      iex> parse_orders("satoshi 10.9 takeshi 390.13")
      [{"satoshi", 10.9}, {"takeshi", 390.13}]
      iex> parse_orders("+vat +service")
      []
      iex> parse_orders("")
      []
  """
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

  @doc """
  Extract options (anything beginning with +/-) out of
  the input text into the list

  ## Example
      iex> parse_options("d 10 a 200 +vat +service")
      ["+vat", "+service"]
      iex> parse_options("a 500 +v +s b 200 +t")
      ["+v", "+s", "+t"]
      iex> parse_options("d 10 a 200 +7% +10% -5%")
      ["+7%", "+10%", "-5%"]
      iex> parse_options("d 10 a 200 z 200")
      []
      iex> parse_options("")
      []
  """
  @spec parse_options(String.t()) :: list()
  def parse_options(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn s -> option?(s) end)
  end

  defp option?(string), do: String.match?(string, ~r/^[+-]/)
end
