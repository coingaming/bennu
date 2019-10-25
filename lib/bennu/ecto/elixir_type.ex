defmodule Bennu.Ecto.ElixirType do
  use Ecto.Type
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

  def type, do: :string

  def cast(<<"Elixir.", _::binary>> = x) do
    try do
      with mod <- String.to_existing_atom(x),
           # sacrifice performance to satisfy Dialyzer (opaque type MapSet.t)
           {false, ^mod} <- {@kernel_types |> MapSet.new() |> MapSet.member?(mod), mod},
           :ok <- try_load(mod),
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

  def try_load(module) do
    _ = Code.ensure_loaded(module)

    try do
      module.__info__(:functions)
      # this String.to_atom is safe because module exists
      module
      |> Module.split()
      |> Enum.each(&String.to_atom/1)
    rescue
      _ -> :ok
    end

    :ok
  end
end
