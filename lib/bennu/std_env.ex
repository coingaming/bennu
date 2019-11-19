defmodule Bennu.StdEnv do
  require Bennu.Env, as: Env

  envs = [
    %Env{name: "page_title", type: BitString},
    %Env{name: "page_meta_description", type: BitString},
    %Env{name: "page_meta_keywords", type: BitString}
  ]

  envs
  |> Enum.each(fn %Env{name: name} ->
    defmacro unquote(name |> String.to_atom())() do
      unquote(name)
    end
  end)

  envs
  |> Enum.each(fn %Env{name: name, type: type} ->
    def type_of(unquote(name)) do
      unquote(type)
    end
  end)

  defmacro list do
    unquote(envs |> Macro.escape())
    |> Macro.escape()
  end
end
