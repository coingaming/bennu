use Bennu.Component.Grid
require Bennu.ResponsiveBootstrap, as: ResponsiveBootstrap

defrender type: Grid,
          design: Design.default_coreui(),
          input: %Input{items_responsive_bootstrap: responsive},
          context: %RenderContext{socket: %Socket{} = socket} do
  %ResponsiveBootstrap{
    xs: xs,
    sm: sm,
    md: md,
    lg: lg,
    xl: xl
  } =
    case responsive do
      [] -> ResponsiveBootstrap.default()
      [%ResponsiveBootstrap{} = data] -> data
    end

  renderer = fn %Input{items: items} ->
    assigns = %{
      socket: socket,
      items: items,
      item_class: "col-#{xs} col-xs-#{xs} col-sm-#{sm} col-md-#{md} col-lg-#{lg} col-xl-#{xl}"
    }

    ~l"""
    .row
      = for x <- @items do
        div class=@item_class = x
    """
  end

  {renderer, %Output{}}
end
