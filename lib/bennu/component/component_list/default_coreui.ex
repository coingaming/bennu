use Bennu.Component.ComponentList

defrender type: ComponentList,
          design: Design.default_coreui(),
          input: %Input{},
          context: %RenderContext{} do
  {
    fn %Input{items: items} -> items end,
    %Output{}
  }
end
