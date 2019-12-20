defprotocol Bennu.Schema do
  validate(schema, data)
  get(schema, data, path)
  put(schema, data, path, value)
end
