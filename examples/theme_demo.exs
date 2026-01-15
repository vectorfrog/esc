#!/usr/bin/env elixir
# Theme demo script - run with: mix run examples/theme_demo.exs

alias Esc.Theme

# Helper to print section headers
defmodule Demo do
  def section(title) do
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("  #{title}")
    IO.puts(String.duplicate("=", 60) <> "\n")
  end

  def theme_preview(name) do
    theme = Theme.Palette.get(name)

    IO.puts("Theme: #{name}")
    IO.puts(String.duplicate("-", 40))

    # Show color palette using style(theme)
    colors = [
      {:error, "Error"},
      {:warning, "Warning"},
      {:success, "Success"},
      {:header, "Header"},
      {:emphasis, "Emphasis"},
      {:muted, "Muted"}
    ]

    for {semantic, label} <- colors do
      text =
        Esc.style(theme)
        |> Esc.foreground(semantic)
        |> Esc.render(String.pad_trailing(label, 12))

      IO.write(text)
    end

    IO.puts("\n")
  end
end

Demo.section("Theme Feature Demo")

IO.puts("""
Esc supports 12 built-in themes from popular terminal color schemes.
Use themes with: Esc.style(:theme_name) |> Esc.foreground(:color)

Available themes: #{Enum.join(Esc.themes(), ", ")}
""")

Demo.section("Theme Previews")

# Show previews of a few themes
for theme <- [:nord, :dracula, :gruvbox, :monokai] do
  Demo.theme_preview(theme)
end

Demo.section("Semantic Colors")

theme = Theme.Palette.get(:nord)

IO.puts("Themes provide semantic colors for common UI purposes:\n")

colors = [
  {:header, "Header text, titles"},
  {:emphasis, "Important, emphasized text"},
  {:error, "Error messages"},
  {:warning, "Warning messages"},
  {:success, "Success messages"},
  {:muted, "Subdued text, borders"}
]

for {semantic, desc} <- colors do
  label =
    Esc.style(theme)
    |> Esc.foreground(semantic)
    |> Esc.bold()
    |> Esc.render(String.pad_trailing(":#{semantic}", 12))

  IO.puts("  #{label} - #{desc}")
end

Demo.section("Style with Theme")

IO.puts("Pass theme to style() for clean, explicit theming:\n")

IO.puts("  # No global state needed!")
IO.puts("  Esc.style(:dracula)")
IO.puts("  |> Esc.foreground(:error)")
IO.puts("  |> Esc.render(\"Error message\")\n")

dracula = Theme.Palette.get(:dracula)

error_msg =
  Esc.style(dracula)
  |> Esc.foreground(:error)
  |> Esc.render("Error: Something went wrong")

success_msg =
  Esc.style(dracula)
  |> Esc.foreground(:success)
  |> Esc.render("Success: Operation completed")

warning_msg =
  Esc.style(dracula)
  |> Esc.foreground(:warning)
  |> Esc.render("Warning: Check your input")

IO.puts("  #{error_msg}")
IO.puts("  #{success_msg}")
IO.puts("  #{warning_msg}")

Demo.section("ANSI Color Names")

IO.puts("Standard ANSI color names resolve through the theme:\n")

nord = Theme.Palette.get(:nord)

ansi_colors = [
  :black,
  :red,
  :green,
  :yellow,
  :blue,
  :magenta,
  :cyan,
  :white
]

IO.write("  ")

for color <- ansi_colors do
  styled =
    Esc.style(nord)
    |> Esc.foreground(color)
    |> Esc.render(String.pad_trailing(to_string(color), 9))

  IO.write(styled)
end

IO.puts("")
IO.write("  ")

for color <- ansi_colors do
  bright = :"bright_#{color}"

  styled =
    Esc.style(nord)
    |> Esc.foreground(bright)
    |> Esc.render(String.pad_trailing(to_string(bright), 9))

  IO.write(styled)
end

IO.puts("")

Demo.section("Mixing Themes")

IO.puts("Different elements can use different themes:\n")

gruvbox = Theme.Palette.get(:gruvbox)

nord_text =
  Esc.style(nord)
  |> Esc.foreground(:emphasis)
  |> Esc.bold()
  |> Esc.render("Nord theme")

gruvbox_text =
  Esc.style(gruvbox)
  |> Esc.foreground(:emphasis)
  |> Esc.bold()
  |> Esc.render("Gruvbox theme")

IO.puts("  #{nord_text}  vs  #{gruvbox_text}")

Demo.section("Styled Box Example")

IO.puts("Create themed UI elements with borders:\n")

for theme_name <- [:nord, :dracula, :gruvbox] do
  t = Theme.Palette.get(theme_name)

  box =
    Esc.style(t)
    |> Esc.border(:rounded)
    |> Esc.border_foreground(:muted)
    |> Esc.padding(0, 2)
    |> Esc.foreground(:header)
    |> Esc.bold()
    |> Esc.render(String.pad_trailing(to_string(theme_name), 10))

  box
  |> String.split("\n")
  |> Enum.each(&IO.puts("  " <> &1))
end

Demo.section("Direct Theme Color Access")

IO.puts("Access theme colors with Esc.Theme.color/2:\n")

IO.puts("  Theme.color(nord, :error)   => #{inspect(Theme.color(nord, :error))}")
IO.puts("  Theme.color(nord, :success) => #{inspect(Theme.color(nord, :success))}")
IO.puts("  Theme.color(nord, :red)     => #{inspect(Theme.color(nord, :red))}")

Demo.section("All 12 Themes")

IO.puts("Quick preview of all available themes:\n")

for theme_name <- Esc.themes() do
  theme = Theme.Palette.get(theme_name)

  name = String.pad_trailing("#{theme_name}", 12)

  sample =
    Esc.style(theme)
    |> Esc.foreground(:foreground)
    |> Esc.background(:background)
    |> Esc.render(" #{name} ")

  colors =
    for i <- 0..7 do
      Esc.style(theme)
      |> Esc.foreground(:"ansi_#{i}")
      |> Esc.render("*")
    end

  IO.puts("  #{sample}  #{Enum.join(colors, " ")}")
end

IO.puts("\n")
