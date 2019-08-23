use Bennu.Component.Flash

defrender type: Flash,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{conn: %Conn{assigns: conn_assigns}} do
  renderer = fn %Input{} ->
    assigns = %{
      info: conn_assigns[:flash][:info],
      warn: conn_assigns[:flash][:warn],
      error: conn_assigns[:flash][:error]
    }

    ~l"""
    = if @info do
      .alert.alert-info role="alert"
        = @info
    = if @warn do
      .alert.alert-warning role="alert"
        = @warn
    = if @error do
      .alert.alert-danger role="alert"
        = @error
    """
  end

  {renderer, %Output{}}
end
