defmodule Chopperbot.LineMessageBuilderTest do
  use ExUnit.Case, async: true

  alias Chopperbot.LineMessageBuilder

  describe "validate_text_input/1" do
    test "returns {:error, suggestion_text} if the given text has invalid format" do
      [
        "slice chopper 100 luffy 200 +v",
        "chopper 100 luffy 200 +v"
      ]
      |> Enum.each(fn text ->
        result = LineMessageBuilder.validate_text_input(text)

        assert {:error, suggestion_text} = result

        assert suggestion_text =~
                 "Now I can help you split the bill 💸! Just type `split` following by orders."
      end)
    end

    test "returns {:ok, text} if the given text has valid format" do
      [
        "Split chopper 100 luffy 200 +v",
        " split chopper 100 luffy 200 +v ",
        "split chopper 100 luffy 200 +v"
      ]
      |> Enum.each(fn text ->
        result = LineMessageBuilder.validate_text_input(text)

        assert result == {:ok, "chopper 100 luffy 200 +v"}
      end)
    end
  end

  describe "build_ok_message/1" do
    test "builds a Line flex message from the given orders" do
      orders = [{"chopper", 100}, {"luffy", 200}, {"_total", 300}]

      result = LineMessageBuilder.build_ok_message(orders)

      assert %{
               altText: "Orders summary",
               contents: %{
                 body: %{
                   contents: [
                     %{
                       align: "center",
                       size: "sm",
                       text: _,
                       type: "text",
                       weight: "bold",
                       wrap: true
                     },
                     %{
                       contents: [
                         %{
                           contents: [
                             %{
                               color: "#555555",
                               flex: 0,
                               size: "sm",
                               text: "chopper",
                               type: "text"
                             },
                             %{
                               align: "end",
                               color: "#111111",
                               size: "sm",
                               text: "100.00 THB",
                               type: "text"
                             }
                           ],
                           layout: "horizontal",
                           type: "box"
                         },
                         %{
                           contents: [
                             %{
                               color: "#555555",
                               flex: 0,
                               size: "sm",
                               text: "luffy",
                               type: "text"
                             },
                             %{
                               align: "end",
                               color: "#111111",
                               size: "sm",
                               text: "200.00 THB",
                               type: "text"
                             }
                           ],
                           layout: "horizontal",
                           type: "box"
                         },
                         %{margin: "xxl", type: "separator"},
                         %{
                           contents: [
                             %{
                               color: "#555555",
                               size: "sm",
                               text: "TOTAL",
                               type: "text",
                               weight: "bold"
                             },
                             %{
                               align: "end",
                               color: "#111111",
                               size: "sm",
                               text: "300.00 THB",
                               type: "text",
                               weight: "bold"
                             }
                           ],
                           layout: "horizontal",
                           type: "box"
                         }
                       ],
                       layout: "vertical",
                       margin: "xxl",
                       spacing: "sm",
                       type: "box"
                     }
                   ],
                   layout: "vertical",
                   type: "box"
                 },
                 type: "bubble"
               },
               type: "flex"
             } = result
    end
  end

  describe "build_error_message/1" do
    test "builds a Line text message from the given error text" do
      error_text = "invalid_options: +invalid"

      result = LineMessageBuilder.build_error_message(error_text)

      assert %{text: text, type: "text"} = result
      assert text =~ "invalid_options: +invalid"
    end
  end
end