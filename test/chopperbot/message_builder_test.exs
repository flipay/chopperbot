defmodule Chopperbot.MessageBuilderTest do
  use ExUnit.Case, async: true

  import Mox

  alias Chopperbot.{MessageBuilder, TestMessageBuilder}

  @platform :test

  setup :verify_on_exit!

  describe "build/2" do
    test "returns error message if the given text is invalid" do
      text = "splice chopper 100 luffy 200 +v"
      expected_result = %{text: "error"}

      TestMessageBuilder
      |> expect(:validate_text_input, fn ^text -> {:error, "invalid format"} end)
      |> expect(:build_error_message, fn "invalid format" -> expected_result end)

      result = MessageBuilder.build(text, for: @platform)

      assert result == expected_result
    end

    test "returns error message if the given text has invalid inputs/options" do
      text = "chopper one-hundred luffy 200 +v"
      expected_error_text = "invalid inputs: one-hundred"
      expected_result = %{text: "error"}

      TestMessageBuilder
      |> expect(:validate_text_input, fn ^text -> {:ok, text} end)
      |> expect(:build_error_message, fn ^expected_error_text -> expected_result end)

      result = MessageBuilder.build(text, for: @platform)

      assert result == expected_result
    end

    test "returns ok message if the given text is valid" do
      text = "chopper 100 luffy 200 +v"
      expected_orders = [{"chopper", 107.0}, {"luffy", 214.0}, {"_total", 321.0}]
      expected_result = %{text: "ok"}

      TestMessageBuilder
      |> expect(:validate_text_input, fn ^text -> {:ok, text} end)
      |> expect(:build_ok_message, fn ^expected_orders -> expected_result end)

      result = MessageBuilder.build(text, for: @platform)

      assert result == expected_result
    end
  end
end
