defmodule Chopperbot.Split.Order do
  @type name :: String.t()
  @type amount :: float()
  @type t :: {name(), amount()}
end
