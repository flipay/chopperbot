defmodule Chopperbot.Split.MessageBuilderTest do
  use ExUnit.Case, async: true

  alias Chopperbot.Split.{
    LineMessageBuilder,
    MessageBuilder,
    SlackMessageBuilder,
    TestMessageBuilder
  }

  describe "from_platform/1" do
    test "returns a message builder module from the given platform" do
      assert MessageBuilder.from_platform(:line) == LineMessageBuilder
      assert MessageBuilder.from_platform(:slack) == SlackMessageBuilder
      assert MessageBuilder.from_platform(:test) == TestMessageBuilder
    end

    test "raises an error if the given platform is not supported" do
      assert_raise KeyError, fn ->
        MessageBuilder.from_platform(:telegram)
      end
    end
  end
end
