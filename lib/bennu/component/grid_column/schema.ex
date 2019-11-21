use Bennu.Component

defcomponent Component.GridColumn do
  input do
    content(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
  end
end
