use Bennu.Component.Grid
alias Bennu.Design.Bootstrap

defdesignimpl type: Grid, design: Bootstrap do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    ~l"""
    .container
      = for component(module: mod, assigns: a) <- @rows do
        = live_component @socket, mod, [{:socket, @socket} | a]
    """
  end

end
