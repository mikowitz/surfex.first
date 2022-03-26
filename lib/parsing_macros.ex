defmodule Surfex.ParsingMacros do
  defmacro l32 do
    quote do: little - 32
  end

  defmacro l16 do
    quote do: little - 16
  end

  defmacro ls16 do
    quote do: little - signed - 16
  end

  defmacro ls(x) do
    quote do: little - signed - unquote(x)
  end
end
