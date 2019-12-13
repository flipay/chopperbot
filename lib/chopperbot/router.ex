defmodule Chopperbot.Router do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  post "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/split" do
    body = %{
      "response_type" => "in_channel",
      "text" => "Hey guys! 🤩"
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(body))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
