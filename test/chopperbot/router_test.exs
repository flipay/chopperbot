defmodule Chopperbot.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Chopperbot.Router

  @opts Router.init([])

  describe "post /split" do
    test "builds a Slack message and sends it back via json response" do
      text = "chopper 100 luffy 200 +v"
      params = %{"text" => text}

      conn =
        :post
        |> conn("/split", params)
        |> Router.call(@opts)

      assert conn.status == 200
      assert %{"response_type" => "in_channel", "text" => text} = Jason.decode!(conn.resp_body)
      assert text =~ "chopper: 107.00 THB\nluffy: 214.00 THB\n---\n*total: 321.00 THB*"
    end
  end

  describe "post /line" do
    test "builds a Line message and replies it back to the user via Line client" do
      text = "split chopper 100 luffy 200 +v"
      reply_token = "token123"
      params = %{"events" => [%{"message" => %{"text" => text}, "replyToken" => reply_token}]}
      expect(Linex.TestMessage, :reply, fn _, ^reply_token -> :ok end)

      conn =
        :post
        |> conn("/line", params)
        |> Router.call(@opts)

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{}
      verify!()
    end

    test "sends a suggestion message if the given text is invalid" do
      text = "slice chopper 100 luffy 200 +v"
      reply_token = "token123"
      params = %{"events" => [%{"message" => %{"text" => text}, "replyToken" => reply_token}]}

      msg =
        "Now I can help you split the bill 💸! Just type `split` following by orders. For example...\n\n1️⃣\nsplit alice 100 alice 250 bob 200 +vat +service\n2️⃣\nsplit alice 100 bob 200 +v\n3️⃣\nsplit alice 100 bob 200 share 100"

      expect(Linex.TestMessage, :reply, fn ^msg, ^reply_token -> :ok end)

      conn =
        :post
        |> conn("/line", params)
        |> Router.call(@opts)

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{}
      verify!()
    end
  end

  describe "request to invalid path" do
    test "returns not_found response" do
      conn =
        :post
        |> conn("/invalid")
        |> Router.call(@opts)

      assert conn.status == 404
      assert conn.resp_body == "not found"
    end
  end
end
