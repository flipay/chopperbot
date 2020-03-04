defmodule Chopperbot.SplitTest do
  use ExUnit.Case, async: true

  import Mox

  alias Chopperbot.Split
  alias Chopperbot.Split.TestMessageBuilder

  @platform :test

  describe "process/2" do
    test "returns ok message if the given text is valid" do
      text = "chopper 100 luffy 200 +v"
      expected_orders = [{"chopper", 107.0}, {"luffy", 214.0}, {"_total", 321.0}]
      expected_result = %{text: "ok"}

      TestMessageBuilder
      |> expect(:build_ok_message, fn ^expected_orders -> expected_result end)

      result = Split.process(text, for: @platform)

      assert result == expected_result
    end

    test "returns error message if the given text has invalid inputs" do
      text = "chopper one-hundred luffy 200 +v"
      expected_error_text = "invalid inputs: one-hundred"
      expected_result = %{text: "error"}

      TestMessageBuilder
      |> expect(:build_error_message, fn ^expected_error_text -> expected_result end)

      result = Split.process(text, for: @platform)

      assert result == expected_result
    end

    test "returns error message if the given text has invalid options" do
      text = "chopper 100 luffy 200 +invalid"
      expected_error_text = "invalid options: +invalid"
      expected_result = %{text: "error"}

      TestMessageBuilder
      |> expect(:build_error_message, fn ^expected_error_text -> expected_result end)

      result = Split.process(text, for: @platform)

      assert result == expected_result
    end
  end
end
