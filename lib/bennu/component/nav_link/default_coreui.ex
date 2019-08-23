import PhoenixActiveLink
use Bennu.Component.NavLink

defrender type: NavLink,
          design: Design.default_coreui(),
          input: %Input{src: [src], text: [text], icon: micon, active: mactive},
          context: %RenderContext{conn: %Conn{} = conn} do
  renderer = fn %Input{} ->
    icon =
      micon
      |> List.first()
      |> case do
        nil -> nil
        x -> "nav-icon icon-#{x |> Utils.enum2css_class()}"
      end

    assigns = %{
      src: src,
      text: text,
      icon: icon,
      conn: conn,
      active: List.first(mactive) || :exclusive
    }

    ~l"""
    = active_link @conn, to: @src, class: "nav-link", active: @active do
      = if @icon do
        i class=@icon
      = @text
    """
  end

  {renderer, %Output{}}
end
