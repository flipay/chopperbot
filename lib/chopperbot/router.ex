defmodule Chopperbot.Router do
  use Plug.Router
  alias Chopperbot.{Character, Split}

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  post "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/split" do
    input = conn.body_params["text"]
    response = Character.happy_talk() <> "\n\n" <> Split.run(input)

    body = %{
      "response_type" => "in_channel",
      "text" => response
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(body))
  end

  post "/line" do
    [
      %{
        "message" => %{"text" => text},
        "replyToken" => reply_token
      }
      | _
    ] = conn.params["events"]

    response =
      if text |> String.downcase() |> String.starts_with?("split") do
        ["", input] = text |> String.downcase() |> String.split("split ")
        Character.happy_talk() <> "\n\n" <> Split.run(input)
      else
        [
          "Now I can help you split the bill 💸! Just type `split` following by orders like one of these...",
          "",
          "1️⃣",
          "split alice 100 alice 250 bob 200 +vat +service",
          "2️⃣",
          "split alice 100 bob 200 +v",
          "3️⃣",
          "split alice 100 bob 200 share 100",
        ]
        |> Enum.join("\n")
      end

    Linex.Message.reply(response, reply_token)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{}))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
