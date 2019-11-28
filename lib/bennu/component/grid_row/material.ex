use Bennu.Component.GridRow

defdesignimpl type: GridRow, design: Design.material() do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .mdc-layout-grid__inner
      = for x <- @columns do
        = x
    """
  end

end
