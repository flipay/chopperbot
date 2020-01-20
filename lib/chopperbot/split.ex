defmodule Chopperbot.Split do
  @moduledoc """

  TODO:
  [ ] add support for LINE format
  """

  alias Chopperbot.Split.{Order, Parser}

  @type orders :: list(Order.t())

  @doc """
  Process text input for /split to result

  ## Examples
      iex> run("a 100 a 200 b 300 +v +s")
      {:ok, "a: 353.10 THB\\nb: 353.10 THB\\n---\\n*total: 706.20 THB*"}

      iex> run("a 1100 b 300 share 200 +s")
      {:ok, "a: 1,320.00 THB\\nb: 440.00 THB\\n---\\n*total: 1,760.00 THB*"}

      iex> run("a 1100 b 300 share 200 +invalid -haha")
      {:error, "invalid options: +invalid, -haha"}

      iex> run("a 1100 b 300 share five dollars")
      {:error, "invalid inputs: five, dollars"}
  """
  @spec run(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def run(text) do
    case Parser.parse(text) do
      {:ok, %{orders: orders, multiplier: multiplier}} ->
        result =
          orders
          |> sum_orders_by_name()
          |> split_share()
          |> apply_multiplier(multiplier)
          |> add_total()
          |> format_slack_string()

        {:ok, result}

      {:error, :invalid_option, invalid_options} ->
        error_msg = "invalid options: " <> Enum.join(invalid_options, ", ")
        {:error, error_msg}

      {:error, :invalid_input, invalid_inputs} ->
        error_msg = "invalid inputs: " <> Enum.join(invalid_inputs, ", ")
        {:error, error_msg}
    end
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
  Multiply each order amount with the given multiplier.

  ## Examples
      iex> apply_multiplier([{"a", 100}, {"b", 300}], 1.07)
      [{"a", 107.0}, {"b", 321.0}]
  """
  @spec apply_multiplier(orders(), float()) :: orders()
  def apply_multiplier(orders, multiplier) do
    Enum.map(orders, fn {name, amount} ->
      new_amount = Float.round(amount * multiplier, 15)
      {name, new_amount}
    end)
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
end
