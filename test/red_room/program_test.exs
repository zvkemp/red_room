defmodule RedRoom.ProgramTest do
  use ExUnit.Case

  defmodule ZSample do
    use RedRoom.Program.Methods

    def ingests_left?, do: true
    def emits_right?,  do: true

    # moving dot from left to right
    def step(inbox, prev, index, strip_length, dir) do
      next = case inbox do
        [] -> :blank
        [a|_] -> a
      end

      Enum.split([next|prev], strip_length) |> IO.inspect
    end
  end

  test "foo" do
    assert ZSample.ingests_left?
  end

  test "call" do
    prev = [:blank, :blank, :blank]
    {result, outbox} = ZSample.step([:red], prev, 0, 3, :forward)
    assert result == [:red, :blank, :blank]
    assert outbox == [:blank]
  end
end

# emit modes: :left|:right|:both
#
