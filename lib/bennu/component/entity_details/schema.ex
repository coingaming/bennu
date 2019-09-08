use Bennu.Component

defcomponent Component.EntityDetails do
  input do
    parent_path(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    update_form_name(
      min_qty: 1,
      max_qty: 1,
      type: BitString
    )

    delete_form_name(
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
