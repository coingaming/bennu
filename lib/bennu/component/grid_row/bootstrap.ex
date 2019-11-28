use Bennu.Component.GridRow

defdesignimpl type: GridRow, design: Design.bootstrap() do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .row
      = for x <- @columns do
        = x
    """
  end
end
