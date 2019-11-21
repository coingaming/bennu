use Bennu.Component.GridColumn

defrender type: GridColumn,
          design: Design.material(),
          input: %Input{},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{
                  content: content,
                  width: width,
                  phone_width: phone_width,
                  tablet_width: tablet_width,
                  desktop_width: desktop_width
                } ->
    assigns = %{
      socket: socket,
      content: content,
      width: width,
      phone_width: phone_width,
      tablet_width: tablet_width,
      desktop_width: desktop_width
    }

    class =
      [
        width: width,
        phone_width: phone_width,
        tablet_width: tablet_width,
        desktop_width: desktop_width
      ]
      |> Enum.reduce([], fn
        {:width, [12]}, acc ->
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
        [] -> ["mdc-layout-grid__cell"]
        x -> x
      end
      |> Enum.join(" ")

    ~l"""
    div class=class
      = for x <- @content do
        = x
    """
  end

  {renderer, %Output{}}
end
