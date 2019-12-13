defmodule Chopperbot.SplitTest do
  use ExUnit.Case
  alias Chopperbot.Split

  describe "process_input/1" do
    test "can process input" do
      assert Split.process_input("text") == "text"
    end
  end
end
