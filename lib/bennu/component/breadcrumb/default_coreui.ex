use Bennu.Component.Breadcrumb

defrender type: Breadcrumb,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{
            base_path: base_path,
            path: path
          } do
  {_, links} =
    Enum.reduce(path, {Utils.path_to_string(base_path), []}, fn path_piece, {current_path, acc} ->
      new_path = Path.join(current_path, path_piece)
      {new_path, [new_path | acc]}
    end)

  #
  # TODO : proper breadcrumb names for pages
  #
  renderer = fn %Input{} ->
    assigns = %{
      links:
        links
        |> Enum.reverse()
        |> Enum.map(fn x -> {x, x |> Path.split() |> List.last()} end)
    }

    ~l"""
    = if length(@links) > 1 do
      ol.breadcrumb
        = for {href, default_name} <- @links do
          li.breadcrumb-item
            a href=href
              = default_name
        li.breadcrumb-menu.d-md-down-none
          .btn-group
    - else
      ol.breadcrumb style="padding: 0; border: 0;"
    """
  end

  {renderer, %Output{}}
end
