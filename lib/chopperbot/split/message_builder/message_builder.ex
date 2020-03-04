defmodule Chopperbot.Split.MessageBuilder do
  alias Chopperbot.Split.Order

  @callback build_ok_message([Order.t()]) :: map()
  @callback build_error_message(String.t()) :: map()

  @spec from_platform(atom()) :: module()
  def from_platform(platform) do
    :chopperbot
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(platform)
  end
end
