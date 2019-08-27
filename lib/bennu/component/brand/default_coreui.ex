use Bennu.Component.Brand

defrender type: Brand,
          design: Design.default_coreui(),
          input: %Input{src_full: [src_full], src_min: msrc_min},
          context: %RenderContext{socket: %Socket{} = socket} do
  renderer = fn %Input{} ->
    assigns = %{
      socket: socket,
      src_full: src_full,
      src_min:
        msrc_min
        |> List.first()
        |> case do
          bin when is_binary(bin) -> bin
          nil -> src_full
        end
    }

    ~l"""
    a.navbar-brand href="/"
      img.navbar-brand-full alt=("logo") height="25" src=@src_full width="89" /
      img.navbar-brand-minimized alt=("logo") height="30" src=@src_min width="30" /
    """
  end

  {renderer, %Output{}}
end
