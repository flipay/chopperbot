defmodule Linex.Message do
  @doc """
  Reply the message users send to the channel.
  """
  @spec reply(String.t(), String.t()) :: :ok | {:error, HTTPoison.Error.t()}
  def reply(message, reply_token) do
    url = "https://api.line.me/v2/bot/message/reply"

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Linex.get_conf(:channel_access_token)}"}
    ]

    body = %{
      "replyToken" => reply_token,
      "messages" => [
        %{
          "type" => "text",
          "text" => message
        }
      ]
    }

    with {:ok, %HTTPoison.Response{status_code: 200}} <-
           HTTPoison.post(url, Jason.encode!(body), headers) do
      :ok
    else
      {:error, err} -> {:error, err}
    end
  end
end
