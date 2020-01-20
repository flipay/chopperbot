defmodule Chopperbot.MessageBuilder do
  alias Chopperbot.Split

  @callback validate_text_input(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback build_ok_message([Split.Order.t()]) :: map()
  @callback build_error_message(String.t()) :: map()

  @doc """
  Build a message from the given text and platform.
  """
  @spec build(String.t(), for: atom()) :: map()
  def build(text, for: platform) do
    message_builder = get_message_builder_from_platform(platform)

    with {:ok, validated_text} <- message_builder.validate_text_input(text),
         {:ok, orders} <- Split.run(validated_text) do
      message_builder.build_ok_message(orders)
    else
      {:error, error_text} -> message_builder.build_error_message(error_text)
    end
  end

  defp get_message_builder_from_platform(platform) do
    :chopperbot
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(platform)
  end
end
