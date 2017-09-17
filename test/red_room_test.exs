defmodule RedRoomTest do
  use ExUnit.Case
  doctest RedRoom

  test "greets the world" do
    assert RedRoom.hello() == :world
  end
end
