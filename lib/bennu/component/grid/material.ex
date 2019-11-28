use Bennu.Component.Grid

defdesignimpl type: Grid, design: Design.material() do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .mdc-layout-grid
      = for x <- @rows do
        = x
    """
  end

end
