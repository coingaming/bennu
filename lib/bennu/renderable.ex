defprotocol Bennu.Renderable do
  require Bennu.RenderContext, as: RenderContext

  @type t :: __MODULE__.t()
  @type input :: term
  @type output :: term
  @type html :: {:safe, term} | Phoenix.LiveView.Rendered.t()
  @type renderer :: (input -> html)

  @spec render(t, input, RenderContext.t()) :: {renderer, output}
  def render(t, input, context)
end
