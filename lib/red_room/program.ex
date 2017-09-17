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
    GenServer.start_link(__MODULE__, {0, program_configs})
  end

  def init(state) do
    me = self()
    :timer.send_interval(me, 25, :tick)
    {:ok, state}
  end

  def handle_call(:foo, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call(:tick, _from, {counter, state}) do
    str = Enum.map(state, fn { mod, freq, len, dir } ->
      tick = div(counter, freq)
      Kernel.apply(mod, :step, [tick, len, dir])
    end)
    |> Enum.join

    {:reply, str, {rem(counter + 25, 2000), state}}
  end

  def handle_info(:tick, {counter, configs} = state) do
    # Process.send_after(self(), :tick, 500)
    IO.puts(GenServer.call(self(), :tick))
    {:noreply, state}
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

  def step(index, strip_length \\ @length, dir \\ :forward) do
    @pattern
    |> Stream.cycle
    |> Stream.drop(rem(index, @length))
    |> Enum.take(strip_length)
    |> change_direction(dir)
    |> map_to_dots
    |> Enum.join
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

  def map_to_dots(pattern) do
    pattern
    |> Enum.map(fn
      {0,0,0,0} -> " "
      {255,_,_,_} -> IO.ANSI.format([:red, :bright, "."]) |> IO.chardata_to_string
      {_,255,_,_} -> IO.ANSI.format([:green, :bright, "."]) |> IO.chardata_to_string
      {_,_,255,_} -> IO.ANSI.format([:blue, :bright, "."]) |> IO.chardata_to_string
    end)
  end
end
