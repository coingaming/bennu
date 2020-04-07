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

  def comp_design_module(comp_module, design) do
    [
      Bennu,
      Renderable,
      design,
      comp_module |> Module.split() |> Enum.slice(2..-1)
    ]
    |> List.flatten()
    |> Module.concat()
  end

  def comp_design_impl!(comp_module, design) do
    case comp_design_impl(comp_module, design) do
      {:ok, module} ->
        module

      :error ->
        raise "component #{inspect(comp_module)} not implemented for #{inspect(design)} design"
    end
  end

  def comp_design_impl(comp_module, design) do
    comp_module
    |> comp_design_module(design)
    |> Code.ensure_compiled()
    |> case do
      {:module, module} ->
        {:ok, module}

      _ ->
        design
        |> struct()
        |> Bennu.Design.parent()
        |> case do
          nil ->
            :error

          parent_design ->
            comp_design_impl(comp_module, parent_design)
        end
    end
  end
end
