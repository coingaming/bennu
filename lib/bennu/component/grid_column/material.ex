use Bennu.Component.GridColumn
alias Bennu.Design.Material

defdesignimpl type: GridColumn, design: Material do
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
        {:width, [4]}, acc ->
          ["mdc-layout-grid__cell" | acc]

        {:width, [size]}, acc ->
          ["mdc-layout-grid__cell--span-#{size}" | acc]

        {:phone_width, [size]}, acc ->
          ["mdc-layout-grid__cell--span-#{size}-phone" | acc]

        {:tablet_width, [size]}, acc ->
          ["mdc-layout-grid__cell--span-#{size}-tablet" | acc]

        {:desktop_width, [size]}, acc ->
          ["mdc-layout-grid__cell--span-#{size}-desktop" | acc]

        _, acc ->
          acc
      end)
      |> case do
        [] -> ["mdc-layout-grid__cell--span-12"]
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
