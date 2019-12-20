defmodule StructSchema do
  defstruct fields: []
end

defimpl Bennu.Schema, for: StructSchema do
  def validate(%StructSchema{fields: fields}, data) do
    Enum.all?(fields, fn {key, schema} ->
      &Bennu.Schema.validate(schema, Map.get(data, key))
    end)
  end

  def get(_, data, []) do
    data
  end

  def get(_, data, [field]) when is_atom(field) do
    Map.get(data, field)
  end

  def get(%StructSchema{fields: fields}, data, [field | remaining_path]) when is_atom(field) do
    schema = Keyword.fetch!(fields, field)
    Bennu.Schema.get(schema, Map.get(data, field), remaining_path)
  end

  def put(_, _, [], value) do
    value
  end

  def put(_, data, [field], value) when is_atom(field) do
    Map.put(data, field, value)
  end

  def put(%StructSchema{fields: fields}, data, [field | remaining_path], value)
      when is_atom(field) do
    schema = Keyword.fetch!(fields, field)
    Map.put(data, field, Bennu.Schema.put(schema, Map.get(data, field), remaining_path, value))
  end
end

defimpl Bennu.Schema, for: NavSchema do
  @schema %StructSchema{
    fields: [
      title: %TextSchema{},
      url: %TextSchema{},
      children: %ListSchema{item_schema: %NavSchema{}}
    ]
  }

  def validate(_, data), do: Bennu.Schema.validate(@schema, data)
  def get(_, data, path), do: Bennu.Schema.get(@schema, data, path)
  def put(_, data, path, value), do: Bennu.Schema.put(@schema, data, path, value)
end
