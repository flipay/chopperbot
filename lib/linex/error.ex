defmodule Linex.Error do
  defstruct [:code, :message]

  @type t :: %__MODULE__{
          code: integer(),
          message: String.t()
        }
end
