defmodule Chopperbot.SplitTest do
  use ExUnit.Case
  alias Chopperbot.Split

  doctest Split, import: true

  @sum_orders [
    {"kendo", 300},
    {"neo", 400},
    {"turbo", 300}
  ]

  describe "apply_options/2" do
    test "can add service charge to orders" do
      assert [
               {"kendo", 330},
               {"neo", 440},
               {"turbo", 330}
             ] == Split.apply_options(@sum_orders, ["+s"])
    end

    test "can add vat to orders" do
      assert [
               {"kendo", 321},
               {"neo", 428},
               {"turbo", 321}
             ] == Split.apply_options(@sum_orders, ["+v"])
    end

    test "can add vat & service charge to orders" do
      assert [
               {"kendo", 353.1},
               {"neo", 470.8},
               {"turbo", 353.1}
             ] == Split.apply_options(@sum_orders, ["+v", "+s"])
    end

    test "can use alias of vat & service charge" do
      assert [
               {"kendo", 353.1},
               {"neo", 470.8},
               {"turbo", 353.1}
             ] == Split.apply_options(@sum_orders, ["+vat", "+service"])
    end
  end
end
