defmodule Linex do
  @moduledoc """
  Elixir wrapper for LINE API
  """

  @spec get_conf() :: keyword()
  def get_conf(), do: Application.get_env(:chopperbot, __MODULE__)

  @spec get_conf(atom()) :: any()
  def get_conf(key), do: get_conf()[key]
end
