defmodule Bennu.FontAwesome.Icon do
  import GenEnum

  defenum(
    database_type: :bennu_font_awesome_icon,
    values: [
      :EYE,
      :PLUS,
      :SAVE,
      :BAN
    ]
  )
end
