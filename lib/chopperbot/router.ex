defmodule Chopperbot.Router do
  use Plug.Router

  alias Chopperbot.Split

  @line_message Linex.get_conf(:message)

  plug :match
  plug Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason
  plug :dispatch

  post "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/split" do
    text = conn.body_params["text"]
    message = Split.process(text, for: :slack)

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

    message =
      case normalize_text_input(text) do
        {:ok, normalized_text} ->
          Split.process(normalized_text, for: :line)

        :error ->
          build_line_suggestion_message()
      end

    case @line_message.reply(message, reply_token) do
      :ok ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{}))

      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(error.code, Jason.encode!(error))
    end
  end

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp normalize_text_input(text) do
    text
    |> String.trim()
    |> String.downcase()
    |> case do
      "split " <> input -> {:ok, input}
      _ -> :error
    end
  end

  defp build_line_suggestion_message do
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
