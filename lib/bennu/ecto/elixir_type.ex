defmodule Bennu.Ecto.ElixirType do
  @behaviour Ecto.Type
  @kernel_types [
                  # scalars
                  Atom,
                  BitString,
                  Float,
                  Function,
                  Integer,
                  PID,
                  Port,
                  Reference,
                  # collections
                  Tuple,
                  List,
                  Map,
                  # special case
                  Any
                ]
                |> MapSet.new()

  def type, do: :string

  def cast(<<"Elixir.", _::binary>> = x) do
    try do
      with mod <- String.to_existing_atom(x),
           {false, ^mod} <- {MapSet.member?(@kernel_types, mod), mod},
           {true, ^mod} <- {:erlang.function_exported(mod, :__info__, 1), mod} do
        {:ok, mod}
      else
        {true, mod} -> {:ok, mod}
        {false, _} -> :error
      end
    rescue
      ArgumentError -> :error
    end
  end

  def cast(x) when is_binary(x) do
    cast("Elixir.#{x}")
  end

  def cast(x) when is_atom(x), do: {:ok, x}
  def cast(_), do: :error

  def load(x) when is_binary(x), do: cast(x)

  def dump(x) when is_atom(x), do: {:ok, Atom.to_string(x)}
  def dump(_), do: :error
end
