defmodule Chopperbot.Split.SlackMessageBuilder do
  @behaviour Chopperbot.Split.MessageBuilder

  alias Chopperbot.{Character, MoneyFormatter}

  @impl true
  def build_ok_message(%{orders: orders, total: total}) do
    orders_summary_text =
      orders
      |> Enum.map(fn {name, amount} -> "#{name}: #{MoneyFormatter.format(amount)}" end)
      |> List.insert_at(-1, "---\n*total: #{MoneyFormatter.format(total)}*")
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
