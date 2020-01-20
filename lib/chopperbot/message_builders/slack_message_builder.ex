defmodule Chopperbot.SlackMessageBuilder do
  @behaviour Chopperbot.MessageBuilder

  alias Chopperbot.{Character, MoneyFormatter}

  @impl true
  def validate_text_input(text) do
    {:ok, text}
  end

  @impl true
  def build_ok_message(orders) do
    orders_summary_text =
      orders
      |> Enum.map(fn
        {"_total", amount} -> "---\n*total: #{MoneyFormatter.format(amount)}*"
        {name, amount} -> "#{name}: #{MoneyFormatter.format(amount)}"
      end)
      |> Enum.join("\n")

    %{
      response_type: "in_channel",
      text: Character.happy_talk() <> "\n\n" <> orders_summary_text
    }
  end

  @impl true
  def build_error_message(error_text) do
    %{
      response_type: "in_channel",
      text: Character.confused_talk() <> "\n\n" <> error_text
    }
  end
end
