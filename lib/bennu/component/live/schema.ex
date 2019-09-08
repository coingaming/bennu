use Bennu.Component

defcomponent Component.Live do
  input do
    module(
      min_qty: 1,
      max_qty: 1,
      type: Atom
    )

    session(
      min_qty: 1,
      max_qty: 1,
      type: Any
    )

    container(
      min_qty: 1,
      max_qty: 1,
      type: Any
    )
  end

  output do
  end
end
