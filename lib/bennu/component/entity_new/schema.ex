use Bennu.Component

defcomponent Component.EntityNew do
  input do
    parent_path(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    form_name(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    title(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    live(
      min_qty: 1,
      max_qty: 1,
      type: Live
    )

    compact(
      min_qty: 1,
      max_qty: 1,
      type: Atom
    )
  end

  output do
  end
end
