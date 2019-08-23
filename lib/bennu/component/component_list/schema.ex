use Bennu.Component

defcomponent Component.ComponentList do
  input do
    items(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
  end
end
