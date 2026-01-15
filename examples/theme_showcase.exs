#!/usr/bin/env elixir
# Theme showcase script - displays all content types in a specified theme
# Usage: mix run examples/theme_showcase.exs <theme_name>
# Example: mix run examples/theme_showcase.exs dracula

alias Esc.Theme

defmodule Showcase do
  def run(theme_name) do
    case Theme.Palette.get(theme_name) do
      nil ->
        IO.puts("Unknown theme: #{theme_name}")
        IO.puts("\nAvailable themes: #{Enum.join(Esc.themes(), ", ")}")
        System.halt(1)

      theme ->
        display_showcase(theme_name, theme)
    end
  end

  defp display_showcase(theme_name, theme) do
    # Header
    header_style =
      Esc.style(theme)
      |> Esc.foreground(:foreground)
      |> Esc.background(:background)

    title = "  #{String.upcase(to_string(theme_name))} THEME  "
    IO.puts("\n" <> Esc.render(header_style, String.duplicate(" ", 60)))
    IO.puts(Esc.render(header_style, String.pad_leading(title, 35) <> String.duplicate(" ", 25)))
    IO.puts(Esc.render(header_style, String.duplicate(" ", 60)) <> "\n")

    # Color Palette
    section(theme, "Color Palette")
    show_palette(theme)

    # Semantic Colors
    section(theme, "Semantic Colors")
    show_semantic_colors(theme)

    # ANSI Color Names
    section(theme, "ANSI Color Names")
    show_ansi_colors(theme)

    # Text Styles
    section(theme, "Text Styles")
    show_text_styles(theme)

    # Borders
    section(theme, "Border Styles")
    show_borders(theme)

    # Sample UI
    section(theme, "Sample UI Elements")
    show_sample_ui(theme)

    IO.puts("")
  end

  defp section(theme, title) do
    line =
      Esc.style(theme)
      |> Esc.foreground(:muted)
      |> Esc.render(String.duplicate("-", 50))

    header =
      Esc.style(theme)
      |> Esc.foreground(:header)
      |> Esc.bold()
      |> Esc.render(title)

    IO.puts("\n#{line}")
    IO.puts(header)
    IO.puts("")
  end

  defp show_palette(theme) do
    # Standard colors (0-7)
    IO.write("  Standard:  ")

    for i <- 0..7 do
      block =
        Esc.style(theme)
        |> Esc.background(:"ansi_#{i}")
        |> Esc.render("  #{i} ")

      IO.write(block <> " ")
    end

    IO.puts("")

    # Bright colors (8-15)
    IO.write("  Bright:    ")

    for i <- 8..15 do
      block =
        Esc.style(theme)
        |> Esc.background(:"ansi_#{i}")
        |> Esc.render(" #{String.pad_leading("#{i}", 2)} ")

      IO.write(block <> " ")
    end

    IO.puts("")

    # Background/Foreground
    IO.puts("")

    bg =
      Esc.style(theme)
      |> Esc.background(:background)
      |> Esc.foreground(:foreground)

    IO.puts("  " <> Esc.render(bg, " Background with Foreground text "))
  end

  defp show_semantic_colors(theme) do
    semantics = [
      {:header, "Header"},
      {:emphasis, "Emphasis"},
      {:success, "Success"},
      {:warning, "Warning"},
      {:error, "Error"},
      {:muted, "Muted"}
    ]

    for {semantic, label} <- semantics do
      styled =
        Esc.style(theme)
        |> Esc.foreground(semantic)
        |> Esc.render(String.pad_trailing(label, 12))

      bg_styled =
        Esc.style(theme)
        |> Esc.background(semantic)
        |> Esc.foreground({0, 0, 0})
        |> Esc.render(" #{label} ")

      IO.puts("  #{styled}  #{bg_styled}")
    end
  end

  defp show_ansi_colors(theme) do
    colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]

    IO.write("  ")

    for color <- colors do
      styled =
        Esc.style(theme)
        |> Esc.foreground(color)
        |> Esc.render(String.pad_trailing(to_string(color), 9))

      IO.write(styled)
    end

    IO.puts("")
    IO.write("  ")

    for color <- colors do
      bright = :"bright_#{color}"

      styled =
        Esc.style(theme)
        |> Esc.foreground(bright)
        |> Esc.render(String.pad_trailing(to_string(bright), 14))

      IO.write(styled)
    end

    IO.puts("")
  end

  defp show_text_styles(theme) do
    styles = [
      {&Esc.bold/1, "Bold"},
      {&Esc.italic/1, "Italic"},
      {&Esc.underline/1, "Underline"},
      {&Esc.strikethrough/1, "Strikethrough"},
      {&Esc.faint/1, "Faint"},
      {&Esc.reverse/1, "Reverse"}
    ]

    IO.write("  ")

    for {style_fn, label} <- styles do
      styled =
        Esc.style(theme)
        |> style_fn.()
        |> Esc.foreground(:foreground)
        |> Esc.render(label)

      IO.write(styled <> "  ")
    end

    IO.puts("")

    # Combined styles
    IO.puts("")

    combined =
      Esc.style(theme)
      |> Esc.bold()
      |> Esc.italic()
      |> Esc.foreground(:emphasis)

    IO.puts("  " <> Esc.render(combined, "Bold + Italic + Emphasis"))
  end

  defp show_borders(theme) do
    borders = [:normal, :rounded, :thick, :double, :ascii]

    for border_style <- borders do
      box =
        Esc.style(theme)
        |> Esc.border(border_style)
        |> Esc.padding(0, 1)
        |> Esc.border_foreground(:muted)
        |> Esc.render(String.pad_trailing(to_string(border_style), 8))

      # Indent each line of the box
      box
      |> String.split("\n")
      |> Enum.each(&IO.puts("  " <> &1))
    end
  end

  defp show_sample_ui(theme) do
    # Status badges
    IO.puts("  Status badges:")

    success_badge =
      Esc.style(theme)
      |> Esc.background(:success)
      |> Esc.foreground({0, 0, 0})
      |> Esc.bold()
      |> Esc.render(" PASS ")

    warning_badge =
      Esc.style(theme)
      |> Esc.background(:warning)
      |> Esc.foreground({0, 0, 0})
      |> Esc.bold()
      |> Esc.render(" WARN ")

    error_badge =
      Esc.style(theme)
      |> Esc.background(:error)
      |> Esc.foreground({0, 0, 0})
      |> Esc.bold()
      |> Esc.render(" FAIL ")

    IO.puts("    #{success_badge}  #{warning_badge}  #{error_badge}")

    # Log messages
    IO.puts("")
    IO.puts("  Log messages:")

    info =
      Esc.style(theme)
      |> Esc.foreground(:emphasis)
      |> Esc.render("[INFO]")

    warn =
      Esc.style(theme)
      |> Esc.foreground(:warning)
      |> Esc.render("[WARN]")

    err =
      Esc.style(theme)
      |> Esc.foreground(:error)
      |> Esc.render("[ERROR]")

    muted_style = Esc.style(theme) |> Esc.foreground(:muted)

    IO.puts("    #{info} " <> Esc.render(muted_style, "Application started successfully"))
    IO.puts("    #{warn} " <> Esc.render(muted_style, "Config file not found, using defaults"))
    IO.puts("    #{err} " <> Esc.render(muted_style, "Failed to connect to database"))

    # Progress indicator
    IO.puts("")
    IO.puts("  Progress:")

    filled =
      Esc.style(theme)
      |> Esc.background(:success)
      |> Esc.render(String.duplicate(" ", 24))

    empty =
      Esc.style(theme)
      |> Esc.background(:bright_black)
      |> Esc.render(String.duplicate(" ", 16))

    pct =
      Esc.style(theme)
      |> Esc.foreground(:success)
      |> Esc.bold()
      |> Esc.render("60%")

    IO.puts("    #{filled}#{empty} #{pct}")

    # Code block
    IO.puts("")
    IO.puts("  Code snippet:")

    code_bg =
      Esc.style(theme)
      |> Esc.background(:black)
      |> Esc.foreground(:foreground)

    keyword =
      Esc.style(theme)
      |> Esc.background(:black)
      |> Esc.foreground(:magenta)

    func =
      Esc.style(theme)
      |> Esc.background(:black)
      |> Esc.foreground(:blue)

    string =
      Esc.style(theme)
      |> Esc.background(:black)
      |> Esc.foreground(:green)

    comment =
      Esc.style(theme)
      |> Esc.background(:black)
      |> Esc.foreground(:bright_black)

    IO.puts("    " <> Esc.render(code_bg, "                                        "))

    IO.puts(
      "    " <>
        Esc.render(keyword, "  def ") <>
        Esc.render(func, "hello") <> Esc.render(code_bg, " do                       ")
    )

    IO.puts(
      "    " <>
        Esc.render(code_bg, "    IO.puts ") <>
        Esc.render(string, "\"Hello, World!\"") <> Esc.render(code_bg, "          ")
    )

    IO.puts(
      "    " <>
        Esc.render(keyword, "  end") <>
        Esc.render(code_bg, " ") <>
        Esc.render(comment, "# greeting function") <> Esc.render(code_bg, "        ")
    )

    IO.puts("    " <> Esc.render(code_bg, "                                        "))
  end
end

# Parse command line arguments
case System.argv() do
  [theme_name] ->
    Showcase.run(String.to_atom(theme_name))

  [] ->
    IO.puts("Usage: mix run examples/theme_showcase.exs <theme_name>")
    IO.puts("\nAvailable themes: #{Enum.join(Esc.themes(), ", ")}")
    IO.puts("\nExample: mix run examples/theme_showcase.exs dracula")

  _ ->
    IO.puts("Usage: mix run examples/theme_showcase.exs <theme_name>")
    System.halt(1)
end
