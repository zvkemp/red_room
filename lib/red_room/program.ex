defmodule RedRoom.Program do
  use GenServer # runs as child of LEDStrip supervisors

  def child_spec({program_configs, id}) do
    %{
      start: {__MODULE__, :start_link, program_configs},
      restart: :permanent,
      shutdown: 5000,
      type: :worker,
      id: id
    }
  end

  def start_link(program_configs) do
    state = program_configs |> Enum.map(&config_to_map/1)
    GenServer.start_link(__MODULE__, {0, state})
  end

  defp config_to_map(config) do
    %{config: config, state: [], tick: -1}
  end

  def init(state) do
    me = self()
    Process.register(me, :strip)
    {:ok, state}
  end

  def handle_cast(:shuffle, {counter, states}) do
    {:noreply, {counter, Enum.shuffle(states)}}
  end

  def handle_cast({:unshift, config, max_size}, {counter, states}) do
    new_states = [config_to_map(config)|states] |> Enum.take(max_size)
    {:noreply, {counter, new_states}}
  end

  def handle_cast(:clear, {count, states}) do
    {:noreply, {0, []}}
  end

  def handle_cast(:shift, {count, [_|states]}) do
    {:noreply, {count, states}}
  end

  def handle_cast(:pop, {count, states}) do
    {:noreply, {count, List.pop_at(states, -1)}}
  end

  def handle_call(:tick, _from, {counter, states}) do
    new_states = Task.async_stream(states, fn %{config: {mod, freq, len, dir}, state: current, tick: t} = this_state ->
      tick = div(counter, freq)
      case tick == t do
        true -> this_state
        _ -> %{this_state | state: apply_step(mod, [current, tick, len, dir]), tick: tick}
      end
    end)
    |> Enum.map(fn {:ok, val} -> val end)

    str = new_states |> Enum.map(fn %{ state: s } -> s |> RedRoom.TerminalHelper.map_to_dots end) |> Enum.join

    {:reply, str, {rem(counter + 25, 23900), new_states}}
  end

  defp apply_step(function, args) when is_function(function), do: Kernel.apply(function, args)
  defp apply_step(module, args), do: Kernel.apply(module, :step, args)

  def handle_info(:inspect, state) do
    IO.puts(state |> inspect)
    {:noreply, state}
  end
  def handle_info(:tick, state) do
    IO.puts(GenServer.call(self(), :tick))
    {:noreply, state}
  end
end

defmodule RedRoom.TerminalHelper do
  def map_to_dots(pattern) do
    pattern |> Enum.map(&map_to_dot/1) |> Enum.join
  end

  defp map_to_dot({0,0,0,0}), do: "  "
  defp map_to_dot(:blank), do: "  "
  defp map_to_dot({255,_,_,_}), do: colored_dot(:red)
  defp map_to_dot({_,255,_,_}), do: colored_dot(:green)
  defp map_to_dot({_,_,255,_}), do: colored_dot(:blue)
  defp map_to_dot(color), do: colored_dot(color)
  defp colored_dot(color) do
    [color, :bright, " o"]
    |> Bunt.ANSI.format
    |> IO.chardata_to_string
  end
end

defmodule RedRoom.Program.Sample do
  @length 100 # repeat length,i.e. pattern size
  @loop_interval 25 # ms
  @pattern [
    {255,0,0,100},
    {255,0,0,100},
    {0,255,0,100},
    {0,0,255,100},
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0},
    {0,0,0,0}
  ]

  def step(_prev, index, strip_length \\ @length, dir \\ :forward) do
    @pattern
    |> Stream.cycle
    |> Stream.drop(rem(index, @length))
    |> Enum.take(strip_length)
    |> change_direction(dir)
  end

  def change_direction(e, :forward), do: e
  def change_direction(e, :reverse), do: Enum.reverse(e)

  def simulate(strip_length, step_limit, current_step \\ 0) do
    case current_step >= step_limit do
      true -> :ok
      _ ->
        IO.write("#{IO.ANSI.clear_line}\r")
        IO.write(step(current_step, strip_length))
        Process.sleep(@loop_interval)
        simulate(strip_length, step_limit, current_step + 1)
    end
  end
end

defmodule RedRoom.Program.Methods do
  defmacro __using__(_) do
    quote do
      def rand_color do
        :"color#{Enum.random(16..255)}"
      end

      def ingests_left? do
        false
      end

      def ingests_right? do
        false
      end

      def emits_right? do
        false
      end

      def emits_left? do
        false
      end

      def call(inbox, prev, index, strip_length, dir) do
      end
    end
  end
end

defmodule RedRoom.Program.Sample2 do
  # random dots
  def step(_prev, _index, strip_length, _dir \\ :forward) do
    Stream.repeatedly(fn ->
      if :rand.uniform(10) <= 3 do
        Enum.random([ :red, :yellow, :green, :cyan, :magenta, :blue ])
      else
        {0,0,0,0}
      end
    end)
    |> Enum.take(strip_length)
  end
end

defmodule RedRoom.Program.Sample4 do
  def step(_prev, index, strip_length, _dir \\ :forward) do
    i = rem(index, 239)
    Stream.cycle([:"color#{i + 16}"]) |> Enum.take(rem(index, strip_length))
  end
end

defmodule RedRoom.Program.Sample5 do
  def step(prev, _index, strip_length, _dir \\ :forward) do
    next = (Enum.random(0..10) > 7) && rand_color || :blank
    [next|prev] |> Enum.take(strip_length)
  end

  defp rand_color do
    :"color#{(16..255) |> Enum.random}"
  end
end

defmodule RedRoom.Program.Sample3 do
  @length 5 # repeat length,i.e. pattern size
  @pattern [
    :red, :yellow, :green, :cyan, :blue
  ]

  def step(_prev, index, strip_length \\ @length, dir \\ :forward) do
    @pattern
    |> Stream.cycle
    |> Stream.drop(rem(index, @length))
    |> Enum.take(strip_length)
    |> change_direction(dir)
  end

  def change_direction(e, :forward), do: e
  def change_direction(e, :reverse), do: Enum.reverse(e)
end
