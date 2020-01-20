defmodule Linex.MessageTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  describe "reply/3" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "returns :ok if the message can be replied", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/", fn conn ->
        Plug.Conn.resp(conn, 200, ~s({}))
      end)

      message = %{type: "text", text: "Hello, world!"}
      reply_token = "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA"
      url = "http://localhost:#{bypass.port}/"

      result = Linex.Message.reply(message, reply_token, url)

      assert result == :ok
    end

    test "returns :error if the message cannot be replied", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/", fn conn ->
        Plug.Conn.resp(conn, 401, ~s({"message": "boom!"}))
      end)

      message = %{type: "text", text: "Hello, world!"}
      reply_token = "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA"
      url = "http://localhost:#{bypass.port}/"

      log_error_msg =
        capture_log(fn ->
          result = Linex.Message.reply(message, reply_token, url)

          assert result == :error
        end)

      assert log_error_msg =~ "boom!"
    end
  end
end
