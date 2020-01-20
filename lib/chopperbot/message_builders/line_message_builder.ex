defmodule Chopperbot.LineMessageBuilder do
  @behaviour Chopperbot.MessageBuilder

  alias Chopperbot.{Character, MoneyFormatter}

  @suggestion_text [
                     "Now I can help you split the bill 💸! Just type `split` following by orders. For example...",
                     "",
                     "1️⃣",
                     "split alice 100 alice 250 bob 200 +vat +service",
                     "2️⃣",
                     "split alice 100 bob 200 +v",
                     "3️⃣",
                     "split alice 100 bob 200 share 100"
                   ]
                   |> Enum.join("\n")

  @impl true
  def validate_text_input(text) do
    text
    |> String.trim()
    |> String.downcase()
    |> case do
      "split " <> input ->
        {:ok, input}

      _ ->
        {:error, @suggestion_text}
    end
  end

  @impl true
  def build_ok_message(orders) do
    orders_summary_contents =
      Enum.flat_map(orders, fn
        {"_total", amount} ->
          [
            %{
              type: "separator",
              margin: "xxl"
            },
            %{
              type: "box",
              layout: "horizontal",
              contents: [
                %{
                  type: "text",
                  text: "TOTAL",
                  size: "sm",
                  color: "#555555",
                  weight: "bold"
                },
                %{
                  type: "text",
                  text: MoneyFormatter.format(amount),
                  size: "sm",
                  color: "#111111",
                  align: "end",
                  weight: "bold"
                }
              ]
            }
          ]

        {name, amount} ->
          [
            %{
              type: "box",
              layout: "horizontal",
              contents: [
                %{
                  type: "text",
                  text: name,
                  size: "sm",
                  color: "#555555",
                  flex: 0
                },
                %{
                  type: "text",
                  text: MoneyFormatter.format(amount),
                  size: "sm",
                  color: "#111111",
                  align: "end"
                }
              ]
            }
          ]
      end)

    %{
      type: "flex",
      altText: "Orders summary",
      contents: %{
        type: "bubble",
        body: %{
          type: "box",
          layout: "vertical",
          contents: [
            %{
              type: "text",
              text: Character.happy_talk(),
              weight: "bold",
              size: "sm",
              wrap: true,
              align: "center"
            },
            %{
              type: "box",
              layout: "vertical",
              margin: "xxl",
              spacing: "sm",
              contents: orders_summary_contents
            }
          ]
        }
      }
    }
  end

  @impl true
  def build_error_message(error_text) do
    %{
      type: "text",
      text: Character.confused_talk() <> "\n\n" <> error_text
    }
  end
end
