defmodule Gifter.HTTP.Behavior do
  @callback get(url :: String.t(), body :: Map.t(), headers :: list)
    :: {:ok, Map.t()} | {:error, String.t() | Map.t()}
end
