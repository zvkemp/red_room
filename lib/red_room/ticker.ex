defmodule RedRoom.Ticker do
  use GenServer

  # refresh of 2500, interval of 25 means
  # - one tick will be emitted every 25ms
  # - every 2500ms, the cycle will repeat
  def start_link(supervisor_pid, refresh \\ 2500, interval \\ 25) do
    GenServer.start_link(__MODULE__, {supervisor_pid, interval})
  end

  def init({supervisor_pid, interval}) do
    {:ok, tref} = :timer.send_interval(interval, supervisor_pid, :tick)
    {:ok, {0, tref}}
  end
end
