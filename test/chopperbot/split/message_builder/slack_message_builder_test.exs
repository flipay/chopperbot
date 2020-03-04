defmodule Chopperbot.Split.SlackMessageBuilderTest do
  use ExUnit.Case, async: true

  alias Chopperbot.Split.SlackMessageBuilder

  describe "build_ok_message/1" do
    test "builds a message map for Slack from the given orders" do
      orders = [{"chopper", 100}, {"luffy", 200}, {"_total", 300}]

      result = SlackMessageBuilder.build_ok_message(orders)

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
