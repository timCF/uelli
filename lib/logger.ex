defmodule Uelli.LazyLogger do
  defmacro __using__(_) do
    quote do
      require Logger, as: Elixir.Logger
      require Uelli.LazyLogger, as: Logger
    end
  end
  defmacro error(code) do
    quote do
      Elixir.Logger.error(fn -> unquote(code) end)
    end
  end
  defmacro warn(code) do
    quote do
      Elixir.Logger.warn(fn -> unquote(code) end)
    end
  end
  defmacro info(code) do
    quote do
      Elixir.Logger.info(fn -> unquote(code) end)
    end
  end
  defmacro debug(code) do
    quote do
      Elixir.Logger.debug(fn -> unquote(code) end)
    end
  end
end
