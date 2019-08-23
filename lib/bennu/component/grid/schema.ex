use Bennu.Component

defcomponent Component.Grid do
  input do
    items(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )

    items_responsive_bootstrap(
      min_qty: nil,
      max_qty: 1,
      type: Bennu.ResponsiveBootstrap
    )
  end

  output do
  end
end
