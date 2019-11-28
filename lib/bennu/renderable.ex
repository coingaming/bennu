defprotocol Bennu.Renderable do
  require Bennu.RenderContext, as: RenderContext

  @type t :: __MODULE__.t()
  @type input :: term
  @type output :: term

  @spec evaluate(t, input, RenderContext.t()) :: output
  def evaluate(t, input, context)
end
