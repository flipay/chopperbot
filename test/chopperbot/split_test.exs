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

    test "can add share order" do
      assert [
               {"kendo", 600},
               {"neo", 700},
               {"turbo", 600}
             ] == Split.apply_options(@sum_orders, ["+share900"])
    end

    test "can add share order and service charge" do
      assert [
               {"kendo", 660},
               {"neo", 770},
               {"turbo", 660}
             ] == Split.apply_options(@sum_orders, ["+share900", "+s"])
    end
  end
end
