defmodule Chopperbot.SplitTest do
  use ExUnit.Case, async: true

  import Mox

  alias Chopperbot.Split
  alias Chopperbot.Split.{CalculatedOrdersResult, TestMessageBuilder}

  @platform :test

  describe "process/2" do
    test "returns ok message if the given text is valid" do
      text = "chopper 100 luffy 200 +v"
      expected_result = %{text: "ok"}

      TestMessageBuilder
      |> expect(:build_ok_message, fn %CalculatedOrdersResult{
                                        orders: [{"chopper", 107.0}, {"luffy", 214.0}],
                                        total: 321.0
                                      } ->
        expected_result
      end)

      result = Split.process(text, for: @platform)

      assert result == expected_result
    end

    test "returns error message if the given text is invalid" do
      text = "chopper one-hundred luffy 200 +v"
      expected_result = %{text: "error"}

      TestMessageBuilder
      |> expect(:build_error_message, fn "invalid inputs: one-hundred" ->
        expected_result
      end)

      result = Split.process(text, for: @platform)

      assert result == expected_result
    end
  end
end
