defmodule Bennu.Design do
  import GenEnum

  defenum(
    database_type: :bennu_design,
    values:
      Application.get_env(:bennu, :design_values, [])
      |> Enum.concat([:BOOTSTRAP, :MATERIAL])
      |> Enum.uniq()
  )
end
