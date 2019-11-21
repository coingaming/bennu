use Bennu.Component.GridColumn

defrender type: GridColumn,
          design: Design.bootstrap(),
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
      = for x <- @content do
        = x
    """
  end

  {renderer, %Output{}}
end
