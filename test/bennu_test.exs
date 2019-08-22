defmodule BennuTest do
  use ExUnit.Case
  doctest Bennu

  test "greets the world" do
    assert Bennu.hello() == :world
  end
end
