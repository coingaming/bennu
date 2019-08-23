use Bennu.Component.Button

#
# TODO : more configurable button through Input
#

defrender type: Button,
          design: Design.default_coreui(),
          input: %Input{
            src: msrc,
            text: [text],
            icon: micon,
            bs_color: mbs_color,
            form_name: mform_name,
            onclick: monclick
          },
          context: %RenderContext{} do
  renderer = fn %Input{} ->
    bs_color =
      mbs_color
      |> List.first()
      |> case do
        nil -> BSColor.primary()
        x when BSColorMeta.is_type(x) -> x
      end

    icon =
      micon
      |> List.first()
      |> case do
        nil -> nil
        x -> "fa fa-#{x |> Utils.enum2css_class()} mr-1"
      end

    src = List.first(msrc)
    onclick = List.first(monclick) || ((src && "window.location.href = '#{src}';") || nil)

    form_name =
      case onclick do
        nil -> List.first(mform_name)
        _ -> nil
      end

    assigns = %{
      onclick: onclick,
      class: "btn btn-pill btn-#{bs_color |> Utils.enum2css_class()} mr-2",
      text: text,
      icon: icon,
      form: form_name,
      type: form_name && "submit"
    }

    ~l"""
    button class=@class onclick=@onclick form=@form type=@type
      = if @icon do
        i class=@icon
      = @text
    """
  end

  {renderer, %Output{}}
end
