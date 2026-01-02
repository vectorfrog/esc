# Minimal Select Test
# Run with: mix run examples/select_test.exs

alias Esc.Select

IO.puts("Testing Select component...")
IO.puts("Use arrow keys or j/k to move, Enter to select, q to cancel\n")

result =
  Select.new(["Option A", "Option B", "Option C"])
  |> Select.run()

case result do
  {:ok, choice} -> IO.puts("\nYou selected: #{choice}")
  :cancelled -> IO.puts("\nCancelled")
end
