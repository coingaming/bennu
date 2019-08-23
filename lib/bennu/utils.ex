defmodule Bennu.Utils do
  defmacro __using__(_) do
    quote location: :keep do
      require Bennu.Utils, as: Utils
      import Utils, only: [generate_basic_api: 1]
    end
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

  defmacro generate_basic_api(repo) do
    quote location: :keep do
      require unquote(repo), as: Repo

      @doc """
      Returns the list of #{__MODULE__}

      ## Examples

          iex> all()
          [%#{__MODULE__}{}, ...]

      """
      def all, do: Repo.all(__MODULE__)

      @doc """
      Gets a single #{__MODULE__}
      Raises `Ecto.NoResultsError` if the #{__MODULE__} does not exist

      ## Examples

          iex> get!(123)
          %#{__MODULE__}{}

          iex> get!(456)
          ** (Ecto.NoResultsError)

      """
      def get!(id), do: Repo.get!(__MODULE__, id)

      @doc """
      Creates a #{__MODULE__}

      ## Examples

          iex> create(%{field: value})
          {:ok, %#{__MODULE__}{}}

          iex> create(%{field: bad_value})
          {:error, %Ecto.Changeset{}}

      """
      def create(attrs \\ %{}) do
        %__MODULE__{}
        |> changeset(attrs)
        |> Repo.insert()
      end

      @doc """
      Updates a #{__MODULE__}

      ## Examples

          iex> update(x, %{field: new_value})
          {:ok, %#{__MODULE__}{}}

          iex> update(x, %{field: bad_value})
          {:error, %Ecto.Changeset{}}

      """
      def update(%__MODULE__{} = x, attrs) do
        x
        |> changeset(attrs)
        |> Repo.update()
      end

      @doc """
      Deletes a #{__MODULE__}

      ## Examples

          iex> delete(x)
          {:ok, %#{__MODULE__}{}}

          iex> delete(x)
          {:error, %Ecto.Changeset{}}

      """
      def delete(%__MODULE__{} = x), do: Repo.delete(x)

      @doc """
      Returns an `%Ecto.Changeset{}` for tracking changes

      ## Examples

          iex> change(x)
          %Ecto.Changeset{source: %#{__MODULE__}{}}

      """
      def change(%__MODULE__{} = x), do: changeset(x, %{})

      defoverridable all: 0, get!: 1, create: 1, update: 2, delete: 1, change: 1
    end
  end
end
