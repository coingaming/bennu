defprotocol Bennu.Schema do
  def validate(schema, data)
  def get(schema, data, path)
  def put(schema, data, path, value)
end
