defmodule Bennu.Utils do
  def enum2module(x) when is_atom(x) do
    x |> Atom.to_string() |> String.downcase() |> Macro.camelize()
  end

  def path_to_string([]), do: "/"
  def path_to_string([_ | _] = path), do: Path.join(path)

  def enum2css_class(x) when is_atom(x) and x != nil do
    x
    |> Atom.to_string()
    |> String.downcase()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  def push_path(%Plug.Conn{path_info: path_info}, x) do
    "/#{path_info |> Enum.concat([to_string(x)]) |> Path.join()}"
  end

  def pop_path(%Plug.Conn{path_info: path_info}) do
    "/#{path_info |> Enum.drop(-1) |> Path.join()}"
  end

  def validate_term_ast(list) when is_list(list) do
    list
    |> Enum.each(&(:ok = validate_term_ast(&1)))
  end

  def validate_term_ast({:<<>>, _, x}) do
    validate_term_ast(x)
  end

  def validate_term_ast({:%{}, _, pairs}) when is_list(pairs) do
    pairs
    |> Enum.each(fn {key, value} ->
      :ok = validate_term_ast(key)
      :ok = validate_term_ast(value)
    end)
  end

  def validate_term_ast({:%, _, ast}) do
    :ok = validate_term_ast(ast)
  end

  def validate_term_ast({el1, el2}) do
    :ok = validate_term_ast(el1)
    :ok = validate_term_ast(el2)
  end

  def validate_term_ast({:{}, _, values}) do
    values
    |> Enum.each(&validate_term_ast/1)
  end

  def validate_term_ast({:__aliases__, _, submodules = [_ | _]} = ast) do
    submodules
    |> Enum.each(fn sub ->
      unless is_atom(sub) do
        "wrong submodule #{inspect(sub)} name in AST chunk #{inspect(ast)}"
        |> raise
      end
    end)
  end

  def validate_term_ast(data)
      when is_atom(data) or
             is_binary(data) or
             is_number(data) do
    :ok
  end

  def validate_term_ast(ast) do
    "invalid or unsafe AST term #{inspect(ast)}"
    |> raise
  end

  def comp_design_module(comp_module, design) do
    try do
      [
        Bennu,
        Renderable,
        comp_module |> Module.split() |> Enum.slice(2..-1),
        WithDesign,
        design
      ]
      |> List.flatten()
      |> Module.concat()
    rescue
      _ ->
        raise "component #{inspect(comp_module)} not implemented for #{inspect(design)} design"
    end
  end
end
