defmodule Uelli.LazyLogger do
  defmacro __using__(_) do
    quote do
      require Logger, as: Elixir.Logger
      require Uelli.LazyLogger, as: Logger
    end
  end
  defmacro error(code, metadata \\ []) do
    true = Keyword.keyword?(metadata)
    quote do
      Elixir.Logger.error(fn -> {unquote(code), unquote(metadata)} end)
    end
  end
  defmacro warn(code, metadata \\ []) do
    true = Keyword.keyword?(metadata)
    quote do
      Elixir.Logger.warn(fn -> {unquote(code), unquote(metadata)} end)
    end
  end
  defmacro info(code, metadata \\ []) do
    true = Keyword.keyword?(metadata)
    quote do
      Elixir.Logger.info(fn -> {unquote(code), unquote(metadata)} end)
    end
  end
  defmacro debug(code, metadata \\ []) do
    true = Keyword.keyword?(metadata)
    quote do
      Elixir.Logger.debug(fn -> {unquote(code), unquote(metadata)} end)
    end
  end
end
