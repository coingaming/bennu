use Bennu.Component

defcomponent Component.Column do
  input do
    rows(
      min_qty: nil,
      max_qty: nil,
      type: Any
    )
  end

  output do
  end
end
