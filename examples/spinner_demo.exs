# Spinner Demo Script
# Run with: mix run examples/spinner_demo.exs

alias Esc.Spinner
import Esc

IO.puts("\n🎡 Esc.Spinner Demo\n")
IO.puts(String.duplicate("─", 40))

# Helper to pause between demos
pause = fn ms -> Process.sleep(ms) end

# ------------------------------------------------------------------------------
# Demo 1: Basic spinner with text
# ------------------------------------------------------------------------------
IO.puts("\n1. Basic Spinner\n")

Spinner.new()
|> Spinner.text("Loading...")
|> Spinner.run(fn ->
  pause.(2000)
end)

IO.puts("   ✓ Done!\n")
pause.(500)

# ------------------------------------------------------------------------------
# Demo 2: Different built-in styles
# ------------------------------------------------------------------------------
IO.puts("2. Built-in Styles\n")

styles = [:dots, :line, :circle, :arc, :bounce, :arrows, :box, :pulse]

for style <- styles do
  IO.write("   #{style}: ")

  Spinner.new(style)
  |> Spinner.run(fn -> pause.(1200) end)

  IO.puts("✓")
end

pause.(500)

# ------------------------------------------------------------------------------
# Demo 3: Emoji spinners
# ------------------------------------------------------------------------------
IO.puts("\n3. Emoji Spinners\n")

IO.write("   moon:  ")
Spinner.new(:moon)
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("✓")

IO.write("   clock: ")
Spinner.new(:clock)
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("✓")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 4: Text position
# ------------------------------------------------------------------------------
IO.puts("\n4. Text Position\n")

IO.write("   ")
Spinner.new(:dots)
|> Spinner.text("Text on right (default)")
|> Spinner.run(fn -> pause.(1500) end)
IO.puts("")

IO.write("   ")
Spinner.new(:dots)
|> Spinner.text("Text on left")
|> Spinner.text_position(:left)
|> Spinner.run(fn -> pause.(1500) end)
IO.puts("")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 5: Custom styling
# ------------------------------------------------------------------------------
IO.puts("\n5. Custom Styling\n")

IO.write("   ")
Spinner.new(:arc)
|> Spinner.text("Styled spinner")
|> Spinner.spinner_style(style() |> foreground(:cyan) |> bold())
|> Spinner.text_style(style() |> foreground(:white) |> italic())
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 6: Theme integration
# ------------------------------------------------------------------------------
IO.puts("\n6. Theme Integration\n")

Esc.set_theme(:nord)

IO.write("   ")
Spinner.new(:circle)
|> Spinner.text("Using Nord theme colors")
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

Esc.clear_theme()

pause.(500)

# ------------------------------------------------------------------------------
# Demo 7: Custom frames
# ------------------------------------------------------------------------------
IO.puts("\n7. Custom Frames\n")

IO.write("   ")
Spinner.new(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])
|> Spinner.text("Custom braille pattern")
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

IO.write("   ")
Spinner.new(["[    ]", "[=   ]", "[==  ]", "[=== ]", "[====]", "[ ===]", "[  ==]", "[   =]"])
|> Spinner.text("Progress-like")
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

IO.write("   ")
Spinner.new(["🌍", "🌎", "🌏"])
|> Spinner.text("Around the world")
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 8: Frame rate control
# ------------------------------------------------------------------------------
IO.puts("\n8. Frame Rate Control\n")

IO.write("   ")
Spinner.new(:dots)
|> Spinner.text("Slow (150ms)")
|> Spinner.frame_rate(150)
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

IO.write("   ")
Spinner.new(:dots)
|> Spinner.text("Fast (40ms)")
|> Spinner.frame_rate(40)
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 9: Manual start/stop with text updates
# ------------------------------------------------------------------------------
IO.puts("\n9. Manual Control with Text Updates\n")

IO.write("   ")

pid = Spinner.new(:dots)
|> Spinner.text("Step 1 of 4: Initializing...")
|> Spinner.start()

pause.(1000)
Spinner.update_text(pid, "Step 2 of 4: Downloading...")
pause.(1000)
Spinner.update_text(pid, "Step 3 of 4: Processing...")
pause.(1000)
Spinner.update_text(pid, "Step 4 of 4: Finishing...")
pause.(1000)

Spinner.stop(pid)
IO.puts("Complete!")

pause.(500)

# ------------------------------------------------------------------------------
# Demo 10: Simulated real-world usage
# ------------------------------------------------------------------------------
IO.puts("\n10. Real-world Example\n")

IO.write("   ")
Spinner.new(:arc)
|> Spinner.text("Fetching dependencies...")
|> Spinner.spinner_style(style() |> foreground(:blue))
|> Spinner.run(fn -> pause.(1500) end)
IO.puts("✓ 12 packages")

IO.write("   ")
Spinner.new(:arc)
|> Spinner.text("Compiling project...")
|> Spinner.spinner_style(style() |> foreground(:yellow))
|> Spinner.run(fn -> pause.(2000) end)
IO.puts("✓ 47 modules")

IO.write("   ")
Spinner.new(:arc)
|> Spinner.text("Running tests...")
|> Spinner.spinner_style(style() |> foreground(:cyan))
|> Spinner.run(fn -> pause.(1500) end)
IO.puts("✓ 377 tests passed")

IO.write("   ")
Spinner.new(:arc)
|> Spinner.text("Generating docs...")
|> Spinner.spinner_style(style() |> foreground(:magenta))
|> Spinner.run(fn -> pause.(1000) end)
IO.puts("✓ docs/index.html")

IO.puts("")
IO.puts(String.duplicate("─", 40))
IO.puts("Demo complete! 🎉\n")
