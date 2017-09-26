defmodule RedRoom.LEDStrip do
  use Supervisor # strips maintain their own process trees

  def start_link do
    Supervisor.start_link([
      { RedRoom.Program, {
        [Enum.map(1..6, fn _ -> RedRoom.Demo.rand_config end)],
        :segment_1}
      }
    ], strategy: :one_for_one)
  end
end

defmodule RedRoom.Demo do
  alias RedRoom.Program.{Sample,Sample2,Sample3,Sample4,Sample5}
  # To issue demo commands and watch the output, recommend starting a second IEx process, and running:
  # CTRL-G (user select mode)
  # r 'name@node' 'Elixir.IEx'
  # c 2 (or whatever the new job number is)
  def start_demo do
    {:ok, s} = RedRoom.LEDStrip.start_link
    c = Supervisor.which_children(s) |> Enum.at(0) |> elem(1)
    Process.register(s, :demo_supervisor)
    # Process.register(c, :strip)
  end

  def start_gl_gc do
    GlMutex.start_link
    gc = GameCore.start_link
    {:ok, pid} = Agent.start_link(fn -> gc end)
    Process.register(pid, :gc_config)
  end

  def start_gl do
    if !Process.whereis(:strip), do: start_demo()
    if !Process.whereis(:gc_config), do: start_gl_gc()
    GameCore.load(Agent.get(:gc_config, &(&1)), Lesson03z)
  end

  def rand_config do
    {
      Enum.random([Sample, Sample2, Sample3, Sample4, Sample5, lambda_demo]),
      Enum.random([25,50,75,100,150,200]),
      25,
      Enum.random([:forward, :reverse])
    }
  end

  def unshift_rand, do: unshift(rand_config)

  def prog1(mod \\ RedRoom.Program.Sample3) do
    [
      {mod, 25, 25, :forward},
      {mod, 50, 25, :reverse},
      {mod, 100, 25, :reverse},
      {mod, 100, 25, :forward},
      {mod, 50, 25, :forward},
      {mod, 25, 25, :reverse}
    ] |> Enum.each(&unshift/1)
  end

  def unshift(config), do: GenServer.cast(:strip, {:unshift, config, 6})

  def lambda_demo do
    fn (prev, index, len, dir) ->
      next = Enum.random(0..10) > 7 && Enum.random([:green, :cyan, :yellow, :red, :blue, :magenta]) || :blank
      str = [next|prev] |> Enum.take(div(len, 2))
      dir == :forward && str ++ Enum.reverse(str) || Enum.reverse(str) ++ str
    end
  end


  def unshift_lambda(len \\ 26) do
    unshift({lambda_demo, 50, len, :forward})
  end

  def clear, do: GenServer.cast(:strip, :clear)
  def shift, do: GenServer.cast(:strip, :clear)
  def pop, do: GenServer.cast(:strip, :clear)
  def randomize do
    6 |> times_do(&unshift_rand/0)
  end

  def times_do(0, _), do: :ok
  def times_do(n, f) do
    f.()
    (n - 1) |> times_do(f)
  end


  def print_demo(iterations \\ 250) do
    c = Process.whereis(:strip)
    Stream.interval(25)
    |> Stream.take(iterations)
    |> Enum.each(fn _ ->
      IO.write("#{IO.ANSI.clear_line}\r#{GenServer.call(c, :tick)}")
    end)
  end

  def shuffle, do: GenServer.cast(:strip, :shuffle)
end
