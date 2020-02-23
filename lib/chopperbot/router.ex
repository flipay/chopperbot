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
    response = build_response(input)

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
      text
      |> String.trim()
      |> String.downcase()
      |> case do
        "split " <> input ->
          build_response(input)

        _ ->
          build_line_suggestion_response()
      end

    Linex.Message.reply(response, reply_token)

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

  defp build_response(input_text) do
    case Split.run(input_text) do
      {:ok, ok_msg} ->
        Character.happy_talk() <> "\n\n" <> ok_msg

      {:error, error_msg} ->
        Character.confused_talk() <> "\n\n" <> error_msg
    end
  end

  defp build_line_suggestion_response do
    [
      "Now I can help you split the bill 💸! Just type `split` following by orders. For example...",
      "",
      "1️⃣",
      "split alice 100 alice 250 bob 200 +vat +service",
      "2️⃣",
      "split alice 100 bob 200 +v",
      "3️⃣",
      "split alice 100 bob 200 share 100"
    ]
    |> Enum.join("\n")
  end
end
