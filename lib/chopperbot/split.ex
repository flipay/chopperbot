defmodule Chopperbot.Split do
  @moduledoc """

  TODO:
  [ ] add support for LINE format
  [ ] add flexible discount ex. -10%
  [ ] [Bug] String.split wrong on copy & paste the command in Slack
  """

  @type orders :: list({String.t(), float() | integer()})
  @type options :: list(String.t())

  @doc """
  Process text input for /split to result

  ## Examples
      iex> run("a 100 a 200 b 300 +v +s")
      "a: 353.10 THB\\nb: 353.10 THB\\n---\\n*total: 706.20 THB*"
      iex> run("a 1100 b 300 share 200 +s")
      "a: 1,320.00 THB\\nb: 440.00 THB\\n---\\n*total: 1,760.00 THB*"
  """
  @spec run(String.t()) :: String.t()
  def run(text) do
    %{orders: orders, options: options} = process_input(text)

    orders
    |> sum_orders_by_name()
    |> split_share()
    |> apply_options(options)
    |> add_total()
    |> format_slack_string()
  end

  @doc """
  Convert the list of calculated order to slack-compatible string

  ## Examples
      iex> format_slack_string([{"a", 300}, {"b", 400}, {"c", 300}, {"_total", 1000}])
      "a: 300.00 THB\\nb: 400.00 THB\\nc: 300.00 THB\\n---\\n*total: 1,000.00 THB*"
  """
  @spec format_slack_string(orders()) :: String.t()
  def format_slack_string(total_orders) do
    total_orders
    |> Enum.map(fn
      {"_total", amount} -> "---\n*total: #{format_money(amount)} THB*"
      {name, amount} -> "#{name}: #{format_money(amount)} THB"
    end)
    |> Enum.join("\n")
  end

  defp format_money(amount) do
    round(amount * 100)
    |> Money.new(:THB)
    |> Money.to_string(symbol: false)
  end

  @doc """
  Group and sum the order with the same name from process_input

  ## Examples
      iex> sum_orders_by_name([{"a", 100}, {"a", 200}, {"b", 300}, {"c", 400}])
      [{"a", 300}, {"b", 300}, {"c", 400}]
  """
  @spec sum_orders_by_name(orders()) :: orders()
  def sum_orders_by_name(orders) do
    orders
    |> Enum.group_by(fn {name, _amount} -> name end)
    |> Enum.map(fn {name, orders} -> {name, sum_orders_amount(orders)} end)
  end

  @doc """
  Split the order with name "share" to all other orders equally

  ## Examples
      iex> split_share([{"a", 100}, {"b", 300}, {"share", 400}])
      [{"a", 300.0}, {"b", 500.0}]
  """
  @spec split_share(orders()) :: orders()
  def split_share(orders) do
    case Enum.filter(orders, fn {name, _} -> name == "share" end) do
      [] ->
        orders

      [{"share", share_amount}] ->
        normal_orders = Enum.filter(orders, fn {name, _} -> name != "share" end)
        share_per_order = share_amount / length(normal_orders)
        Enum.map(normal_orders, fn {name, amount} -> {name, amount + share_per_order} end)
    end
  end

  @doc """
  add _total amount to order

  ## Examples
      iex> add_total([{"a", 300}, {"b", 300}, {"c", 400}])
      [{"a", 300}, {"b", 300}, {"c", 400}, {"_total", 1000}]
  """
  @spec add_total(orders()) :: orders()
  def add_total(orders) do
    orders ++ [{"_total", sum_orders_amount(orders)}]
  end

  defp sum_orders_amount(orders) do
    orders
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
  end

  @doc """
  Apply each options to all orders

  ## Examples
      iex> apply_options([{"a", 300}, {"b", 400}], ["+s"])
      [{"a", 330.0}, {"b", 440.0}]
  """
  @spec apply_options(orders(), options()) :: orders()
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

  def apply_options(orders, []), do: orders

  # FIXME: use the proper way to handle the float precision
  defp rounding_floating_problem(float), do: round(float * 100) / 100

  @doc """
  process text into the correct orders & options.

  ## Examples
      iex> process_input("a 100 a 200 b 300 +v +s")
      %{orders: [{"a", 100.0}, {"a", 200.0}, {"b", 300.0}], options: ["+v", "+s"]}
  """
  @spec process_input(String.t()) :: %{orders: orders(), options: options()}
  def process_input(text) do
    %{
      orders: parse_orders(text),
      options: parse_options(text)
    }
  end

  @doc """
  Extract options out of the text into the list.
  will make all name lower case for the sake of comparison.

  ## Example
      iex> parse_orders("turbo 10 kendo 200 +v +s")
      [{"turbo", 10.0}, {"kendo", 200.0}]
      iex> parse_orders("ant 200 pipe 100 share -30 +v +s")
      [{"ant", 200.0}, {"pipe", 100.0}, {"share", -30.0}]
      iex> parse_orders("Neo 310 neo 19 -5%")
      [{"neo", 310.0}, {"neo", 19.0}]
      iex> parse_orders("satoshi 10.9 takeshi 390.13")
      [{"satoshi", 10.9}, {"takeshi", 390.13}]
      iex> parse_orders("+vat +service")
      []
      iex> parse_orders("")
      []
  """
  @spec parse_orders(String.t()) :: orders()
  def parse_orders(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn s -> not option?(s) and s != "" end)
    |> Enum.chunk_every(2)
    |> Enum.map(fn
      [name, amount] ->
        {float_amount, ""} = Float.parse(amount)
        {String.downcase(name), float_amount}
    end)
  end

  @doc """
  Extract options (anything beginning with +/-) out of
  the input text into the list.
  will make all name lower case for the sake of comparison.

  ## Example
      iex> parse_options("d 10 a 200 +vat +service")
      ["+vat", "+service"]
      iex> parse_options("a 500 +V +s b 200 +T")
      ["+v", "+s", "+t"]
      iex> parse_options("d 10 a 200 +7% +10% -5%")
      ["+7%", "+10%", "-5%"]
      iex> parse_options("d 10 a 200 z 200")
      []
      iex> parse_options("")
      []
  """
  @spec parse_options(String.t()) :: options()
  def parse_options(text) do
    text
    |> String.split(" ")
    |> Enum.filter(fn s -> option?(s) end)
    |> Enum.map(&String.downcase/1)
  end

  defp option?(string), do: not number?(string) and String.match?(string, ~r/^[+-]/)

  defp number?(string) do
    with {_float_amount, remaining} <- Float.parse(string) do
      remaining == ""
    else
      _ -> false
    end
  end
end
