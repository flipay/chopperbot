defmodule Chopperbot.Split.LineMessageBuilder do
  use Chopperbot.Split.MessageBuilder

  @impl true
  def build_ok_message(%CalculatedOrdersResult{orders: orders, total: total}) do
    orders_summary_contents =
      orders
      |> Enum.map(fn {name, amount} ->
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
      end)
      |> Enum.concat([
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
              text: MoneyFormatter.format(total),
              size: "sm",
              color: "#111111",
              align: "end",
              weight: "bold"
            }
          ]
        }
      ])

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
