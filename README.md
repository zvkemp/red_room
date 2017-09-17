# RedRoom

Very early WIP

Pattern coordinator for addressing strips of LEDs, and sub-strips there-in. Any substrip
reference can run its own independent program. The compiled results are sent to the
hardware interface on a regular interval (NOTE: not yet, they aren't)

Goals:

- pre-compile a loop of addresses to avoid repeated computation on controller
- allow substrips to be addressed by multiple programs (handle interleaving)
- web interface

As of this writing, a console demo is available, based on the setup currently in LEDStrip.

```elixir
{:ok, s} = RedRoom.LEDStrip.start_link
{_, c, _, _} = Supervisor.which_children(s) |> Enum.at(0)

Stream.interval(25) |> Stream.take(2500) |> 
Enum.each(fn (_) -> 
  str = GenServer.call(c, :tick)
  IO.write("#{IO.ANSI.clear_line}\r#{str}")
end)
```

This should show six sequences of colored dots whizzing by at various speeds and directions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `red_room` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:red_room, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/red_room](https://hexdocs.pm/red_room).

