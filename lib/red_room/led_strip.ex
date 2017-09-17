defmodule RedRoom.LEDStrip do
  use Supervisor # strips maintain their own process trees

  def start_link do
    Supervisor.start_link([
      { RedRoom.Program, {
        [[
          #{RedRoom.Program.Sample, 225, 30, :reverse},
          {RedRoom.Program.Sample, 25, 25, :forward},
          {RedRoom.Program.Sample, 100, 25, :reverse},
          {RedRoom.Program.Sample, 25, 25, :forward},
          {RedRoom.Program.Sample, 25, 25, :reverse},
          {RedRoom.Program.Sample, 75, 25, :forward},
          {RedRoom.Program.Sample, 25, 25, :reverse},
        ]],
        :segment_1}
      }
    ], strategy: :one_for_one)
  end
end
