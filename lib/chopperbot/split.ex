defmodule Chopperbot.Split do
  @spec run(String.t()) :: String.t()
  def run(text) do
    text
    |> process_input()
  end

  @spec process_input(String.t()) :: String.t()
  def process_input(text) do
    text
  end
end
