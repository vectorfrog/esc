# Test TTY access methods
IO.puts("Testing TTY access...\n")

# Test 1: stty without device
IO.puts("1. Testing stty -g (no device):")
case System.cmd("stty", ["-g"], stderr_to_stdout: true) do
  {settings, 0} -> IO.puts("   OK: #{String.trim(settings) |> String.slice(0..30)}...")
  {err, code} -> IO.puts("   FAILED (#{code}): #{String.trim(err)}")
end

# Test 2: stty with -f /dev/tty
IO.puts("\n2. Testing stty -f /dev/tty -g:")
case System.cmd("stty", ["-f", "/dev/tty", "-g"], stderr_to_stdout: true) do
  {settings, 0} -> IO.puts("   OK: #{String.trim(settings) |> String.slice(0..30)}...")
  {err, code} -> IO.puts("   FAILED (#{code}): #{String.trim(err)}")
end

# Test 3: File.open /dev/tty
IO.puts("\n3. Testing File.open /dev/tty:")
case File.open("/dev/tty", [:read, :binary, :raw]) do
  {:ok, f} ->
    File.close(f)
    IO.puts("   OK: /dev/tty opened successfully")
  {:error, reason} ->
    IO.puts("   FAILED: #{reason}")
end

# Test 4: Check if stdin is a tty
IO.puts("\n4. Checking if stdin is a TTY:")
case :io.getopts(:standard_io) do
  opts when is_list(opts) ->
    IO.puts("   IO opts: #{inspect(opts)}")
  error ->
    IO.puts("   Error: #{inspect(error)}")
end

# Test 5: Try using Port to access tty
IO.puts("\n5. Testing Port to /dev/tty:")
try do
  port = Port.open({:spawn, "cat"}, [:binary, :eof])
  Port.close(port)
  IO.puts("   OK: Port opened")
rescue
  e -> IO.puts("   FAILED: #{inspect(e)}")
end

IO.puts("\nDone.")
