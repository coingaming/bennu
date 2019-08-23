defmodule Bennu.ResponsiveBootstrap do
  @type t :: %__MODULE__{
          xs: non_neg_integer,
          sm: non_neg_integer,
          md: non_neg_integer,
          lg: non_neg_integer,
          xl: non_neg_integer
        }

  # values are 1 - 12
  @enforce_keys [
    :xs,
    :sm,
    :md,
    :lg,
    :xl
  ]
  defstruct @enforce_keys

  def default do
    %__MODULE__{
      xs: 12,
      sm: 12,
      md: 6,
      lg: 4,
      xl: 4
    }
  end
end
