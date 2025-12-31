# Color Demo
# Run with: mix run examples/color_demo.exs

import Esc
alias Esc.Color

IO.puts("\n=== Esc Color Demo ===\n")

# 1. Named ANSI colors (foreground)
IO.puts("1. Named ANSI Colors (Foreground):\n")

basic_colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]

IO.puts("   Standard colors:")
for color <- basic_colors do
  label = color |> Atom.to_string() |> String.pad_trailing(10)
  IO.write("   #{render(style() |> foreground(color), label)}")
end
IO.puts("")

IO.puts("\n   Bright colors:")
for color <- basic_colors do
  bright = :"bright_#{color}"
  label = bright |> Atom.to_string() |> String.pad_trailing(14)
  IO.write("   #{render(style() |> foreground(bright), label)}")
end
IO.puts("\n")

# 2. Named ANSI colors (background)
IO.puts("2. Named ANSI Colors (Background):\n")

IO.puts("   Standard backgrounds:")
for color <- basic_colors do
  label = " #{color |> Atom.to_string() |> String.pad_trailing(8)} "
  # Use contrasting text color
  text_color = if color in [:black, :blue, :magenta], do: :white, else: :black
  IO.write("   #{render(style() |> background(color) |> foreground(text_color), label)}")
end
IO.puts("")

IO.puts("\n   Bright backgrounds:")
for color <- basic_colors do
  bright = :"bright_#{color}"
  label = " #{bright |> Atom.to_string() |> String.pad_trailing(14)} "
  text_color = if color in [:black, :blue, :magenta], do: :white, else: :black
  IO.write("   #{render(style() |> background(bright) |> foreground(text_color), label)}")
end
IO.puts("\n")

# 3. ANSI 256 palette
IO.puts("3. ANSI 256 Palette:\n")

IO.puts("   Standard colors (0-15):")
IO.write("   ")
for i <- 0..15 do
  text_color = if i in [0, 1, 4, 5, 8], do: :white, else: :black
  label = i |> Integer.to_string() |> String.pad_leading(3)
  IO.write(render(style() |> background(i) |> foreground(text_color), label))
end
IO.puts("\n")

IO.puts("   Color cube (16-231) - showing every 6th color:")
for row <- 0..5 do
  IO.write("   ")
  for col <- 0..35 do
    idx = 16 + row * 36 + col
    if rem(col, 6) == 0 do
      label = idx |> Integer.to_string() |> String.pad_leading(4)
      text_color = if row < 3, do: :white, else: :black
      IO.write(render(style() |> background(idx) |> foreground(text_color), label))
    end
  end
  IO.puts("")
end
IO.puts("")

IO.puts("   Grayscale ramp (232-255):")
IO.write("   ")
for i <- 232..255 do
  text_color = if i < 244, do: :white, else: :black
  IO.write(render(style() |> background(i) |> foreground(text_color), "  "))
end
IO.puts("\n")

# 4. True color (RGB tuples)
IO.puts("4. True Color (RGB Tuples):\n")

IO.puts("   Red gradient:")
IO.write("   ")
for i <- 0..15 do
  r = trunc(i * 255 / 15)
  IO.write(render(style() |> background({r, 0, 0}), "  "))
end
IO.puts("")

IO.puts("\n   Green gradient:")
IO.write("   ")
for i <- 0..15 do
  g = trunc(i * 255 / 15)
  IO.write(render(style() |> background({0, g, 0}), "  "))
end
IO.puts("")

IO.puts("\n   Blue gradient:")
IO.write("   ")
for i <- 0..15 do
  b = trunc(i * 255 / 15)
  IO.write(render(style() |> background({0, 0, b}), "  "))
end
IO.puts("")

IO.puts("\n   Rainbow:")
IO.write("   ")
rainbow = [
  {255, 0, 0},      # Red
  {255, 127, 0},    # Orange
  {255, 255, 0},    # Yellow
  {127, 255, 0},    # Lime
  {0, 255, 0},      # Green
  {0, 255, 127},    # Spring
  {0, 255, 255},    # Cyan
  {0, 127, 255},    # Azure
  {0, 0, 255},      # Blue
  {127, 0, 255},    # Violet
  {255, 0, 255},    # Magenta
  {255, 0, 127}     # Rose
]
for rgb <- rainbow do
  IO.write(render(style() |> background(rgb), "    "))
end
IO.puts("\n")

# 5. True color (Hex strings)
IO.puts("5. True Color (Hex Strings):\n")

hex_colors = [
  {"#ff5733", "Coral"},
  {"#33ff57", "Lime"},
  {"#3357ff", "Blue"},
  {"#f333ff", "Magenta"},
  {"#33fff3", "Cyan"},
  {"#fff333", "Yellow"},
  {"#ff33a1", "Pink"},
  {"#a133ff", "Purple"}
]

for {hex, name} <- hex_colors do
  label = " #{String.pad_trailing(name, 8)} #{hex} "
  IO.puts("   #{render(style() |> background(hex) |> foreground(:black) |> bold(), label)}")
end
IO.puts("")

# 6. Color combinations with text styles
IO.puts("6. Color + Text Style Combinations:\n")

combinations = [
  {"Bold + Red", style() |> bold() |> foreground(:red)},
  {"Italic + Cyan", style() |> italic() |> foreground(:cyan)},
  {"Underline + Green", style() |> underline() |> foreground(:green)},
  {"Bold + Yellow on Blue", style() |> bold() |> foreground(:yellow) |> background(:blue)},
  {"Faint + Magenta", style() |> faint() |> foreground(:magenta)},
  {"Reverse + White", style() |> reverse() |> foreground(:white)},
  {"Strikethrough + Red", style() |> strikethrough() |> foreground(:red)},
  {"Bold + Italic + Underline + Cyan", style() |> bold() |> italic() |> underline() |> foreground(:cyan)}
]

for {label, s} <- combinations do
  IO.puts("   #{render(s, label)}")
end
IO.puts("")

# 7. Pastel colors
IO.puts("7. Pastel Colors (using RGB):\n")

pastels = [
  {{255, 182, 193}, "Light Pink"},
  {{255, 218, 185}, "Peach"},
  {{255, 255, 186}, "Light Yellow"},
  {{186, 255, 201}, "Mint"},
  {{186, 225, 255}, "Light Blue"},
  {{221, 186, 255}, "Lavender"}
]

for {rgb, name} <- pastels do
  label = " #{String.pad_trailing(name, 14)} "
  IO.write("   #{render(style() |> background(rgb) |> foreground(:black), label)}")
end
IO.puts("\n")

# 8. Terminal theme colors
IO.puts("8. Terminal Theme Colors:\n")

themes = [
  {"Dracula", [
    {"Background", "#282a36", :white},
    {"Current Line", "#44475a", :white},
    {"Foreground", "#f8f8f2", :black},
    {"Comment", "#6272a4", :white},
    {"Cyan", "#8be9fd", :black},
    {"Green", "#50fa7b", :black},
    {"Orange", "#ffb86c", :black},
    {"Pink", "#ff79c6", :black},
    {"Purple", "#bd93f9", :black},
    {"Red", "#ff5555", :black},
    {"Yellow", "#f1fa8c", :black}
  ]},
  {"Nord", [
    {"Polar Night", "#2e3440", :white},
    {"Snow Storm", "#eceff4", :black},
    {"Frost 1", "#8fbcbb", :black},
    {"Frost 2", "#88c0d0", :black},
    {"Aurora Red", "#bf616a", :white},
    {"Aurora Orange", "#d08770", :black},
    {"Aurora Yellow", "#ebcb8b", :black},
    {"Aurora Green", "#a3be8c", :black},
    {"Aurora Purple", "#b48ead", :black}
  ]}
]

for {theme_name, colors} <- themes do
  IO.puts("   #{theme_name}:")
  for {name, hex, text_color} <- colors do
    label = " #{String.pad_trailing(name, 14)} #{hex} "
    IO.puts("      #{render(style() |> background(hex) |> foreground(text_color), label)}")
  end
  IO.puts("")
end

# 9. Color profile detection
IO.puts("9. Color Profile Detection:\n")

profile = Esc.color_profile()
IO.puts("   Current terminal color profile: #{profile}")
IO.puts("   Dark background detected: #{Esc.has_dark_background?()}")
IO.puts("")

# 10. Color degradation
IO.puts("10. Color Degradation (RGB to ANSI 256):\n")

rgb_samples = [
  {255, 0, 0, "Pure Red"},
  {0, 255, 0, "Pure Green"},
  {0, 0, 255, "Pure Blue"},
  {255, 128, 0, "Orange"},
  {128, 0, 128, "Purple"},
  {0, 128, 128, "Teal"},
  {192, 192, 192, "Silver"},
  {64, 64, 64, "Dark Gray"}
]

for {r, g, b, name} <- rgb_samples do
  ansi256 = Color.rgb_to_ansi256(r, g, b)
  ansi16 = Color.ansi256_to_ansi16(ansi256)

  true_label = " True Color "
  a256_label = " ANSI 256 (#{ansi256}) "
  a16_label = " ANSI 16 (#{ansi16}) "

  IO.puts("   #{String.pad_trailing(name, 12)}:")
  IO.write("      ")
  IO.write(render(style() |> background({r, g, b}) |> foreground(:black), true_label))
  IO.write(" -> ")
  IO.write(render(style() |> background(ansi256) |> foreground(:black), a256_label))
  IO.write(" -> ")
  IO.puts(render(style() |> background(ansi16) |> foreground(:black), a16_label))
end
IO.puts("")

# 11. Adaptive colors
IO.puts("11. Adaptive Colors:\n")

IO.puts("   Adaptive colors change based on terminal background:")
adaptive = Color.adaptive(:black, :white)
light_color = Color.resolve_adaptive(adaptive, :light)
dark_color = Color.resolve_adaptive(adaptive, :dark)
IO.puts("   On light background: #{light_color}")
IO.puts("   On dark background: #{dark_color}")
IO.puts("")

# 12. Complete colors
IO.puts("12. Complete Colors:\n")

IO.puts("   Complete colors specify exact values for each profile:")
complete = Color.complete(ansi: :red, ansi256: 196, true_color: {255, 0, 0})
IO.puts("   ANSI:       #{inspect(Color.resolve_complete(complete, :ansi))}")
IO.puts("   ANSI 256:   #{inspect(Color.resolve_complete(complete, :ansi256))}")
IO.puts("   True Color: #{inspect(Color.resolve_complete(complete, :true_color))}")
IO.puts("")

# 13. Styled boxes with colors
IO.puts("13. Colored Boxes:\n")

boxes = [
  {"Error", style() |> border(:rounded) |> border_foreground(:red) |> foreground(:red) |> padding(0, 1)},
  {"Warning", style() |> border(:rounded) |> border_foreground(:yellow) |> foreground(:yellow) |> padding(0, 1)},
  {"Success", style() |> border(:rounded) |> border_foreground(:green) |> foreground(:green) |> padding(0, 1)},
  {"Info", style() |> border(:rounded) |> border_foreground(:cyan) |> foreground(:cyan) |> padding(0, 1)}
]

for {label, s} <- boxes do
  text = render(s, label)
  text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
end
IO.puts("")

# 14. Color wheel
IO.puts("14. HSL Color Wheel (approximated with RGB):\n")

# Simple HSL to RGB conversion for hue variation
hsl_to_rgb = fn hue ->
  h = hue / 60
  x = trunc(255 * (1 - abs(rem(trunc(h * 100), 200) / 100 - 1)))

  cond do
    hue < 60 -> {255, x, 0}
    hue < 120 -> {x, 255, 0}
    hue < 180 -> {0, 255, x}
    hue < 240 -> {0, x, 255}
    hue < 300 -> {x, 0, 255}
    true -> {255, 0, x}
  end
end

IO.write("   ")
for i <- 0..35 do
  hue = i * 10
  rgb = hsl_to_rgb.(hue)
  IO.write(render(style() |> background(rgb), "  "))
end
IO.puts("\n")

# 15. Brand colors
IO.puts("15. Popular Brand Colors:\n")

brands = [
  {"GitHub", "#24292e"},
  {"GitLab", "#fc6d26"},
  {"Slack", "#4a154b"},
  {"Discord", "#5865f2"},
  {"Twitter/X", "#1da1f2"},
  {"Facebook", "#1877f2"},
  {"LinkedIn", "#0a66c2"},
  {"YouTube", "#ff0000"},
  {"Spotify", "#1db954"},
  {"Netflix", "#e50914"},
  {"Elixir", "#4e2a8e"},
  {"Phoenix", "#f15524"}
]

for {name, hex} <- brands do
  label = " #{String.pad_trailing(name, 12)} #{hex} "
  text_color = if name in ["Spotify"], do: :black, else: :white
  IO.puts("   #{render(style() |> background(hex) |> foreground(text_color) |> bold(), label)}")
end
IO.puts("")

# 16. Syntax highlighting colors
IO.puts("16. Syntax Highlighting Theme:\n")

code_sample = """
   defmodule #{render(style() |> foreground(:yellow), "Example")} do
     @moduledoc #{render(style() |> foreground(:green), "\"\"\"Example module.\"\"\"")}

     #{render(style() |> foreground(:magenta), "def")} #{render(style() |> foreground(:cyan), "hello")}(#{render(style() |> foreground(:red), "name")}) do
       #{render(style() |> foreground(:magenta), "if")} #{render(style() |> foreground(:red), "name")} do
         #{render(style() |> foreground(:green), "\"Hello, \#{name}!\"")}
       #{render(style() |> foreground(:magenta), "else")}
         #{render(style() |> foreground(:green), "\"Hello, World!\"")}
       #{render(style() |> foreground(:magenta), "end")}
     #{render(style() |> foreground(:magenta), "end")}
   #{render(style() |> foreground(:magenta), "end")}
"""
IO.puts(code_sample)
IO.puts("")

IO.puts("=== Demo Complete ===\n")
