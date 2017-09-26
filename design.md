ProgramList:
  [
    {<PID>, ingest_mode, emit_mode},
    {<PID>, ingest_mode, emit_mode},
    {<PID>, ingest_mode, emit_mode},
    {<PID>, ingest_mode, emit_mode}
  ]

EX:

# possible combinations:
[
  {pid, :right, :left},
  {pid, :none, :both},  #  <-  * ->
  {pid, :left, :right},
  {pid, :both, :none}

  {pid, :left, :none}
  {pid, :right, :none}
  {pid, :none, :left}
  {pid, :none, :right}

  # example: receive from left, and bounce it back
  #
  # {pid, :left, :left}
  #
  #
]
