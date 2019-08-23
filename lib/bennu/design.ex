defmodule Bennu.Design do
  import GenEnum

  defenum(
    database_type: :bennu_design,
    values: [
      :DEFAULT_COREUI
    ]
  )
end
