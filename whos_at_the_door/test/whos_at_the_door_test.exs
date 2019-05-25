defmodule WhosAtTheDoorTest do
  use ExUnit.Case
  doctest WhosAtTheDoor

  test "greets the world" do
    assert WhosAtTheDoor.hello() == :world
  end
end
