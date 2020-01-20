defmodule Chopperbot.Split.OrderCalculator do
  alias Chopperbot.Split.Order

  @type orders :: [Order.t()]

  @doc """
  Calculate the given orders.

  ## Examples
      iex> calculate([{"a", 100}, {"b", 200}, {"c", 300}], 1.177)
      [{"a", 117.7}, {"b", 235.4}, {"c", 353.1}, {"_total", 706.2}]

      iex> calculate([{"a", 100}, {"b", 200}, {"a", 300}], 1.177)
      [{"a", 470.8}, {"b", 235.4}, {"_total", 706.2}]

      iex> calculate([{"a", 100}, {"b", 200}, {"c", 300}, {"share", 300}], 1.177)
      [{"a", 235.4}, {"b", 353.1}, {"c", 470.8}, {"_total", 1059.3}]
  """
  @spec calculate(orders(), float()) :: orders()
  def calculate(orders, multiplier) do
    orders
    |> sum_orders_by_name()
    |> split_share()
    |> apply_multiplier(multiplier)
    |> add_total()
  end

  @doc """
  Group and sum the orders with the same name.

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
  Split the order with name "share" to all other orders equally.

  ## Examples
      iex> split_share([{"a", 100}, {"b", 300}, {"share", 400}])
      [{"a", 300.0}, {"b", 500.0}]
  """
  @spec split_share(orders()) :: orders()
  def split_share(orders) do
    case Enum.split_with(orders, fn {name, _} -> name == "share" end) do
      {[], ^orders} ->
        orders

      {[{"share", share_amount}], normal_orders} ->
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
  Add _total amount to orders.

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
