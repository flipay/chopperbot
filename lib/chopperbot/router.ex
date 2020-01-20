defmodule Chopperbot.Router do
  use Plug.Router

  alias Chopperbot.MessageBuilder

  @line_message Linex.get_conf(:message)

  plug :match
  plug Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason
  plug :dispatch

  post "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/split" do
    text = conn.body_params["text"]
    message = MessageBuilder.build(text, for: :slack)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(message))
  end

  post "/line" do
    [
      %{
        "message" => %{"text" => text},
        "replyToken" => reply_token
      }
      | _
    ] = conn.params["events"]

    text
    |> MessageBuilder.build(for: :line)
    |> @line_message.reply(reply_token)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{}))
  end

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
