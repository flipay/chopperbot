defmodule Linex.Error do
  @derive Jason.Encoder

  defstruct [:code, :message]

  @type t :: %__MODULE__{
          code: integer(),
          message: String.t()
        }
end
