defmodule Chopperbot.Split.InputTransformer do
  # TODO:
  # - Rename transform!/1 to transform/1
  # - Handle invalid inputs by changing its behaviour to return
  #     {:ok, term} when all inputs are valid
  #     {:error, term} when there is at least 1 invalid input

  alias Chopperbot.Split.Order

  @doc """
  Transform inputs to a list of orders.

  ## Examples
      iex> transform!(["turbo", "10", "kendo", "200"])
      [{"turbo", 10.0}, {"kendo", 200.0}]

      iex> transform!(["ant", "200", "pipe", "100", "share", "-30"])
      [{"ant", 200.0}, {"pipe", 100.0}, {"share", -30.0}]

      iex> transform!(["Satoshi", "10.9", "Takeshi", "390.13", "satoshi", "112.50",])
      [{"satoshi", 10.9}, {"takeshi", 390.13}, {"satoshi", 112.5}]

      iex> transform!([])
      []

      iex> transform!(["turbo", "ten", "kendo", "200"])
      ** (MatchError) no match of right hand side value: :error

      iex> transform!(["turbo", "100", "kendo", "200", "chopper"])
      ** (FunctionClauseError) no function clause matching in anonymous fn/1 in Chopperbot.Split.InputTransformer.transform!/1
  """
  @spec transform!([String.t()]) :: [Order.t()]
  def transform!(inputs) do
    inputs
    |> Enum.chunk_every(2)
    |> Enum.map(fn [name, amount] ->
      {float_amount, ""} = Float.parse(amount)
      {String.downcase(name), float_amount}
    end)
  end
end
