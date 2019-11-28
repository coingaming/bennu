use Bennu.Component.GridColumn

defdesignimpl type: GridColumn, design: Design.bootstrap() do
  use Phoenix.LiveComponent

  def evaluate(_, %Input{}, %RenderContext{}) do
    %Output{}
  end

  def render(assigns) do
    %{
      width: width,
      phone_width: phone_width,
      tablet_width: tablet_width,
      desktop_width: desktop_width
    } = assigns

    class =
      [
        width: width,
        phone_width: phone_width,
        tablet_width: tablet_width,
        desktop_width: desktop_width
      ]
      |> Enum.reduce([], fn
        {:width, [12]}, acc ->
          ["col" | acc]

        {:width, [size]}, acc ->
          ["col-#{size}" | acc]

        {:phone_width, [4]}, acc ->
          ["col-xs" | acc]

        {:phone_width, [size]}, acc ->
          ["col-xs-#{size * 3}" | acc]

        {:tablet_width, [6]}, acc ->
          ["col-md" | acc]

        {:tablet_width, [size]}, acc ->
          ["col-md-#{size * 2}" | acc]

        {:desktop_width, [12]}, acc ->
          ["col-xl" | acc]

        {:desktop_width, [size]}, acc ->
          ["col-xl-#{size}" | acc]

        _, acc ->
          acc
      end)
      |> case do
        [] -> ["col"]
        x -> x
      end
      |> Enum.join(" ")

    ~l"""
    div class=class
      = for component(module: mod, assigns: a) <- @content do
        = live_component @socket, mod, [{:socket, @socket} | a]
    """
  end

end
