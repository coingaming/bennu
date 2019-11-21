use Bennu.Component

defcomponent Component.Grid do
  input do
    rows(
      min_qty: nil,
      max_qty: nil,
      type: Component.GridRow
    )
  end

  output do
  end
end
