defmodule ChopperbotTest do
  use ExUnit.Case
  doctest Chopperbot

  test "greets the world" do
    assert Chopperbot.hello() == :world
  end
end
