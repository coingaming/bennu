defmodule Bennu.Bootstrap.Color do
  import GenEnum

  defenum(
    database_type: :bennu_bootstrap_color,
    values: [
      :PRIMARY,
      :SECONDARY,
      :SUCCESS,
      :DANGER,
      :WARNING,
      :INFO,
      :LIGHT,
      :DARK
    ]
  )
end
