defprotocol Bennu.Componentable do
  require Bennu.Componentable.Schema, as: Schema

  @type t :: Bennu.Component.t()

  @spec input_schema(t) :: Schema.t()
  def input_schema(t)
  @spec output_schema(t) :: Schema.t()
  def output_schema(t)
end
