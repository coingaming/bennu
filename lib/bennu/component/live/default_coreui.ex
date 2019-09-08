use Bennu.Component.Live

defrender type: Live,
          design: Design.default_coreui(),
          input: %Input{module: [module], session: [%{} = session], container: [container]},
          context: %RenderContext{index: index, socket: socket} do
  {
    fn %Input{} ->
      socket
      |> Phoenix.LiveView.live_render(
        module,
        child_id: index,
        session: session,
        container: container
      )
    end,
    %Output{}
  }
end
