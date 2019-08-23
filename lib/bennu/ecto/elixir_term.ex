defmodule Bennu.Ecto.ElixirTerm do
  @behaviour Ecto.Type
  use Bennu.Utils

  def type, do: :string

  def cast(x) do
    x
    |> dump()
    |> case do
      {:ok, _} ->
        {
          :ok,
          x
          |> Code.format_string!()
          |> Enum.join()
        }

      :error ->
        :error
    end
  end

  def load(x) when is_binary(x) do
    x
    |> Code.string_to_quoted()
    |> case do
      {:ok, x_ast} ->
        try do
          :ok = Utils.validate_term_ast(x_ast)
          {x_term, _} = Code.eval_quoted(x_ast)
          {:ok, x_term}
        catch
          _, _ ->
            :error
        end

      {:error, _} ->
        :error
    end
  end

  def dump(x) when is_binary(x) do
    x
    |> load()
    |> case do
      {:ok, _} -> {:ok, x}
      :error -> :error
    end
  end

  def dump(x) do
    code =
      x
      |> Macro.escape()
      |> Macro.postwalk(fn
        {:%{}, [], [{:__struct__, type} | xs]} ->
          {:%, [],
           [
             {:__aliases__, [alias: false],
              type |> Module.split() |> Enum.map(&String.to_existing_atom/1)},
             {:%{}, [], xs}
           ]}

        otherwise ->
          otherwise
      end)
      |> Macro.to_string()
      |> Code.format_string!()
      |> Enum.join()

    {:ok, code}
  end
end
