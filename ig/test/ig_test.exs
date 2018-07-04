defmodule IgTest do
  use ExUnit.Case
  doctest Ig

  test "greets the world" do
    assert Ig.hello() == :world
  end
end
