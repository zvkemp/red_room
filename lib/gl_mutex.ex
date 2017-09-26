defmodule GlMutex do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, nil}
  end

  def run(fun) do
    GenServer.call(__MODULE__, {:mutex, fun})
  end

  def lock do
    # GenServer.call(__MODULE__, :lock)
    {:ok, true}
  end

  def unlock do
    GenServer.call(__MODULE__, :unlock)
  end

  def handle_call(:lock, from, nil) do
    ref = make_ref()
    {:reply, {:ok, ref}, {from, ref}}
  end

  def handle_call(:lock, _from, state) do
    {:reply, :error, state}
  end

  def handle_call(:unlock, from, nil) do
    {:reply, :ok, nil}
  end

  def handle_call(:unlock, from, {pid, _ref} = state) do
    if pid == from do
      {:reply, :ok, nil}
    else
      {:reply, :error, state}
    end
  end

  def handle_call({:mutex, fun}, _from, _state) do
    IO.inspect(:FOO)
    {
      :reply,
      fun.(),
      nil
    }
  end
end
