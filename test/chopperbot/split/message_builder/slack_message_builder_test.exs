defmodule Chopperbot.Split.SlackMessageBuilderTest do
  use ExUnit.Case, async: true

  alias Chopperbot.Split.{CalculatedOrdersResult, SlackMessageBuilder}

  describe "build_ok_message/1" do
    test "builds a message map for Slack from the given orders" do
      calculated_orders_result = %CalculatedOrdersResult{
        orders: [{"chopper", 100}, {"luffy", 200}],
        total: 300
      }

      result = SlackMessageBuilder.build_ok_message(calculated_orders_result)

      assert %{response_type: "in_channel", text: text} = result
      assert text =~ "chopper: 100.00 THB\nluffy: 200.00 THB\n---\n*total: 300.00 THB*"
    end
  end

  describe "build_error_message/1" do
    test "builds a message map for Slack from the given error text" do
      error_text = "invalid_options: +invalid"

      result = SlackMessageBuilder.build_error_message(error_text)

      assert %{response_type: "in_channel", text: text} = result
      assert text =~ "invalid_options: +invalid"
    end
  end
end
