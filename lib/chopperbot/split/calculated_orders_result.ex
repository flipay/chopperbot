defmodule Chopperbot.Split.CalculatedOrdersResult do
  alias Chopperbot.Split.Order

  @enforce_keys [:orders, :total]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          orders: [Order.t()],
          total: Order.amount()
        }
end
