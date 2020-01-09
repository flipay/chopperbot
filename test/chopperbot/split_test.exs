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

    test "can apply a percentage discount to orders" do
      assert [
               {"kendo", 270.0},
               {"neo", 360.0},
               {"turbo", 270.0}
             ] == Split.apply_options(@sum_orders, ["-10%"])
    end

    test "can apply a percentage addition to orders" do
      assert [
               {"kendo", 330.0},
               {"neo", 440.0},
               {"turbo", 330.0}
             ] == Split.apply_options(@sum_orders, ["+10%"])
    end

    test "raises an error exception if an invalid option is given" do
      assert_raise MatchError, fn ->
        Split.apply_options(@sum_orders, ["+invalid"])
      end
    end
  end
end
