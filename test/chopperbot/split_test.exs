defmodule Chopperbot.SplitTest do
  use ExUnit.Case
  alias Chopperbot.Split

  describe "format_to_string/1" do
    test "can format list total to string" do
      assert "kendo 300\nneo 400\nturbo 300\n_total 1000" ==
               Split.format_string([
                 {"kendo", 300},
                 {"neo", 400},
                 {"turbo", 300},
                 {"_total", 1000}
               ])
    end
  end

  describe "calculate_total/1" do
    test "can sum the amount by name with total" do
      parsed_input = %{
        orders: [
          {"turbo", 100},
          {"turbo", 200},
          {"kendo", 300},
          {"neo", 400}
        ],
        options: []
      }

      assert [
               {"kendo", 300},
               {"neo", 400},
               {"turbo", 300},
               {"_total", 1000}
             ] == Split.calculate_total(parsed_input)
    end
  end

  describe "process_input/1" do
    test "can process normal input" do
      assert %{
               orders: [
                 {"turbo", 100},
                 {"turbo", 200},
                 {"kendo", 300},
                 {"neo", 400}
               ],
               options: ["+v", "+s"]
             } == Split.process_input("turbo 100 turbo 200 kendo 300 neo 400 +v +s")
    end
  end

  describe "parse_option/1" do
    test "filter out the options beginning with + or -" do
      assert ["+vat", "+service"] == Split.parse_options("d 10 a 200 +vat +service")
      assert ["+v", "+s"] == Split.parse_options("d 10 a 200 +v +s")
      assert ["+v"] == Split.parse_options("d 10 a 200 +v")
      assert ["+7%", "+10%"] == Split.parse_options("d 10 a 200 +7% +10%")
      assert ["-5%"] == Split.parse_options("d 10 a 200 -5%")
    end

    test "return empty list when no options" do
      assert [] == Split.parse_options("d 10 a 200 z 200")
      assert [] == Split.parse_options("")
    end
  end

  describe "parse_orders/1" do
    test "filter out the orders (anything that does not begin with + or -)" do
      assert [{"turbo", 10}, {"kendo", 200}] == Split.parse_orders("turbo 10 kendo 200 +v +s")
      assert [{"neo", 310}] == Split.parse_orders("neo 310 -5%")
    end

    test "filter out the orders and can parse float" do
      assert [{"satoshi", 10.9}, {"takeshi", 390.13}] ==
               Split.parse_orders("satoshi 10.9 takeshi 390.13")
    end

    test "return empty list when no orders" do
      assert [] == Split.parse_orders("+vat +service")
      assert [] == Split.parse_orders("")
    end
  end
end
