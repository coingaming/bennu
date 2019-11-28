use Bennu.Component.Grid

defdesignimpl type: Grid, design: Design.bootstrap() do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .container
      = for x <- @rows do
        = x
    """
  end

end
