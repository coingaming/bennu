defmodule Bennu.Env.OnDuplicate do
  import GenEnum

  defenum(
    database_type: :bennu_env_on_duplicate,
    values: [
      :RAISE,
      :IGNORE,
      :REPLACE,
      :UNION,
      :INTERSECTION
    ]
  )
end
