use Bennu.Component.GridRow
alias Bennu.Design.Bootstrap

defdesignimpl type: GridRow, design: Bootstrap do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .row
      = for component(module: mod, assigns: a) <- @columns do
        = live_component @socket, mod, [{:socket, @socket} | a]
    """
  end
end
