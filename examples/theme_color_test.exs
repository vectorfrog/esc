# Theme-aware color resolution test
# Run with: mix run examples/theme_color_test.exs

import Esc

IO.puts("\n=== Theme-aware Color Resolution Test ===\n")

IO.puts("1. Standard ANSI (no theme):")
IO.puts(style() |> foreground(:red) |> render("  Red"))
IO.puts(style() |> foreground(:cyan) |> render("  Cyan"))
IO.puts("")

IO.puts("2. Nord theme:")
IO.puts(style(:nord) |> foreground(:red) |> render("  Red (Nord)"))
IO.puts(style(:nord) |> foreground(:cyan) |> render("  Cyan (Nord)"))
IO.puts("")

IO.puts("3. Dracula theme:")
IO.puts(style(:dracula) |> foreground(:red) |> render("  Red (Dracula)"))
IO.puts(style(:dracula) |> foreground(:cyan) |> render("  Cyan (Dracula)"))
IO.puts("")

IO.puts("4. All ANSI color names (Nord):")

[
  :black,
  :red,
  :green,
  :yellow,
  :blue,
  :magenta,
  :cyan,
  :white,
  :bright_black,
  :bright_red,
  :bright_green,
  :bright_yellow,
  :bright_blue,
  :bright_magenta,
  :bright_cyan,
  :bright_white
]
|> Enum.each(fn color ->
  IO.puts(style(:nord) |> foreground(color) |> render("  #{color}"))
end)

IO.puts("")
IO.puts("5. Semantic colors (Nord theme):")

[:header, :emphasis, :warning, :error, :success, :muted]
|> Enum.each(fn color ->
  IO.puts(style(:nord) |> foreground(color) |> render("  #{color}"))
end)

IO.puts("")
IO.puts("6. Semantic colors (no theme - ANSI fallback):")

[:header, :emphasis, :warning, :error, :success, :muted]
|> Enum.each(fn color ->
  IO.puts(style() |> foreground(color) |> render("  #{color}"))
end)

IO.puts("")
IO.puts("✓ Test complete!")
