use Bennu.Component

defcomponent Component.GridRow do
  input do
    columns(
      min_qty: nil,
      max_qty: nil,
      type: Component.GridColumn
    )
  end

  output do
  end
end
