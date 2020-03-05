defmodule Linex.Message do
  alias Linex.Error

  require Logger

  @reply_url "https://api.line.me/v2/bot/message/reply"

  @callback reply(map(), String.t()) :: :ok | :error

  @doc """
  Reply the message users send to the channel.

  ## Message examples:

    text_message = %{
      type: "text",
      text: "Hello, world!"
    }

    flex_message = %{
      type: "flex",
      altText: "this is a flex message",
      contents: %{
        type: "bubble",
        body: %{
          type: "box",
          layout: "vertical",
          contents: [
            %{type: "text", text: "hello"},
            %{type: "text", text: "world"}
          ]
        }
      }
    }

  ref: https://developers.line.biz/en/reference/messaging-api/#message-objects
  """
  @spec reply(map(), String.t(), String.t()) :: :ok | {:error, Error.t()}
  def reply(message, reply_token, url \\ @reply_url) when is_map(message) do
    body = build_request_body(message, reply_token)
    headers = build_headers()

    url
    |> HTTPoison.post!(Jason.encode!(body), headers)
    |> handle_response()
  end

  defp build_request_body(message, reply_token) do
    %{
      messages: [message],
      replyToken: reply_token
    }
  end

  defp build_headers do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Linex.get_conf(:channel_access_token)}"}
    ]
  end

  defp handle_response(%HTTPoison.Response{status_code: 200}) do
    :ok
  end

  defp handle_response(%HTTPoison.Response{status_code: status_code, body: body} = resp) do
    Logger.error(fn -> inspect(resp) end)

    error =
      case Jason.decode(body) do
        {:ok, %{"message" => message}} -> %Error{code: status_code, message: message}
        _ -> %Error{code: status_code, message: "HTTP request error"}
      end

    {:error, error}
  end
end
