use Bennu.Component

defcomponent Component.Table do
  input do
    header(
      min_qty: nil,
      max_qty: 1,
      type: ComponentList
    )

    rows(
      min_qty: nil,
      max_qty: nil,
      type: ComponentList
    )
  end

  output do
  end
end
