#!/usr/bin/env elixir
# Theme showcase script - displays all content types in a specified theme
# Usage: mix run examples/theme_showcase.exs <theme_name>
# Example: mix run examples/theme_showcase.exs dracula

alias Esc.{Table, Tree, List}

defmodule Showcase do
  def run(theme_name) do
    case Esc.set_theme(theme_name) do
      {:error, :unknown_theme} ->
        IO.puts("Unknown theme: #{theme_name}")
        IO.puts("\nAvailable themes: #{Enum.join(Esc.themes(), ", ")}")
        System.halt(1)

      :ok ->
        display_showcase(theme_name)
    end
  end

  defp display_showcase(theme_name) do
    theme = Esc.get_theme()

    # Header
    header_style = Esc.style() |> Esc.foreground(theme.foreground) |> Esc.background(theme.background)
    title = "  #{String.upcase(to_string(theme_name))} THEME  "
    IO.puts("\n" <> Esc.render(header_style, String.duplicate(" ", 60)))
    IO.puts(Esc.render(header_style, String.pad_leading(title, 35) <> String.duplicate(" ", 25)))
    IO.puts(Esc.render(header_style, String.duplicate(" ", 60)) <> "\n")

    # Color Palette
    section("Color Palette")
    show_palette(theme)

    # Semantic Colors
    section("Semantic Colors")
    show_semantic_colors()

    # Text Styles
    section("Text Styles")
    show_text_styles()

    # Borders
    section("Border Styles")
    show_borders()

    # Table
    section("Table Component")
    show_table()

    # Tree
    section("Tree Component")
    show_tree()

    # List
    section("List Component")
    show_list()

    # Sample UI
    section("Sample UI Elements")
    show_sample_ui()

    IO.puts("")
  end

  defp section(title) do
    muted = Esc.theme_color(:muted)
    line = Esc.style() |> Esc.foreground(muted) |> Esc.render(String.duplicate("─", 50))
    header = Esc.style() |> Esc.theme_foreground(:header) |> Esc.bold() |> Esc.render(title)
    IO.puts("\n#{line}")
    IO.puts(header)
    IO.puts("")
  end

  defp show_palette(theme) do
    # Standard colors (0-7)
    IO.write("  Standard:  ")
    for i <- 0..7 do
      color = Map.get(theme, :"ansi_#{i}")
      block = Esc.style() |> Esc.background(color) |> Esc.render("  #{i} ")
      IO.write(block <> " ")
    end
    IO.puts("")

    # Bright colors (8-15)
    IO.write("  Bright:    ")
    for i <- 8..15 do
      color = Map.get(theme, :"ansi_#{i}")
      block = Esc.style() |> Esc.background(color) |> Esc.render(" #{String.pad_leading("#{i}", 2)} ")
      IO.write(block <> " ")
    end
    IO.puts("")

    # Background/Foreground
    IO.puts("")
    bg = Esc.style() |> Esc.background(theme.background) |> Esc.foreground(theme.foreground)
    IO.puts("  " <> Esc.render(bg, " Background with Foreground text "))
  end

  defp show_semantic_colors do
    semantics = [
      {:header, "Header"},
      {:emphasis, "Emphasis"},
      {:success, "Success"},
      {:warning, "Warning"},
      {:error, "Error"},
      {:muted, "Muted"}
    ]

    for {semantic, label} <- semantics do
      styled = Esc.style() |> Esc.theme_foreground(semantic) |> Esc.render(String.pad_trailing(label, 12))
      bg_styled = Esc.style() |> Esc.theme_background(semantic) |> Esc.foreground({0, 0, 0}) |> Esc.render(" #{label} ")
      IO.puts("  #{styled}  #{bg_styled}")
    end
  end

  defp show_text_styles do
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
      styled = Esc.style() |> style_fn.() |> Esc.theme_foreground(:foreground) |> Esc.render(label)
      IO.write(styled <> "  ")
    end
    IO.puts("")

    # Combined styles
    IO.puts("")
    combined = Esc.style() |> Esc.bold() |> Esc.italic() |> Esc.theme_foreground(:emphasis)
    IO.puts("  " <> Esc.render(combined, "Bold + Italic + Emphasis"))
  end

  defp show_borders do
    borders = [:normal, :rounded, :thick, :double, :ascii]

    for border_style <- borders do
      box =
        Esc.style()
        |> Esc.border(border_style)
        |> Esc.padding(0, 1)
        |> Esc.theme_border_foreground(:muted)
        |> Esc.render(String.pad_trailing(to_string(border_style), 8))

      # Indent each line of the box
      box
      |> String.split("\n")
      |> Enum.each(&IO.puts("  " <> &1))
    end
  end

  defp show_table do
    Table.new()
    |> Table.headers(["Package", "Version", "Status"])
    |> Table.row(["esc", "0.2.0", "Active"])
    |> Table.row(["phoenix", "1.7.10", "Active"])
    |> Table.row(["ecto", "3.11.1", "Active"])
    |> Table.border(:rounded)
    |> Table.render()
    |> String.split("\n")
    |> Enum.each(&IO.puts("  " <> &1))
  end

  defp show_tree do
    tree =
      Tree.root("my_app")
      |> Tree.child("lib")
      |> Tree.child(
        Tree.root("lib/my_app")
        |> Tree.child("application.ex")
        |> Tree.child("repo.ex")
      )
      |> Tree.child("test")
      |> Tree.child("mix.exs")

    tree
    |> Tree.enumerator(:rounded)
    |> Tree.render()
    |> String.split("\n")
    |> Enum.each(&IO.puts("  " <> &1))
  end

  defp show_list do
    IO.puts("  Bullet list:")
    List.new(["First item", "Second item", "Third item"])
    |> List.enumerator(:bullet)
    |> List.indent(4)
    |> List.render()
    |> IO.puts()

    IO.puts("")
    IO.puts("  Numbered list:")
    List.new(["Install dependencies", "Configure database", "Run migrations"])
    |> List.enumerator(:arabic)
    |> List.indent(4)
    |> List.render()
    |> IO.puts()
  end

  defp show_sample_ui do
    theme = Esc.get_theme()

    # Status badges
    IO.puts("  Status badges:")
    success_badge = Esc.style() |> Esc.background(Esc.theme_color(:success)) |> Esc.foreground({0, 0, 0}) |> Esc.bold() |> Esc.render(" PASS ")
    warning_badge = Esc.style() |> Esc.background(Esc.theme_color(:warning)) |> Esc.foreground({0, 0, 0}) |> Esc.bold() |> Esc.render(" WARN ")
    error_badge = Esc.style() |> Esc.background(Esc.theme_color(:error)) |> Esc.foreground({0, 0, 0}) |> Esc.bold() |> Esc.render(" FAIL ")
    IO.puts("    #{success_badge}  #{warning_badge}  #{error_badge}")

    # Log messages
    IO.puts("")
    IO.puts("  Log messages:")
    info = Esc.style() |> Esc.theme_foreground(:emphasis) |> Esc.render("[INFO]")
    warn = Esc.style() |> Esc.theme_foreground(:warning) |> Esc.render("[WARN]")
    err = Esc.style() |> Esc.theme_foreground(:error) |> Esc.render("[ERROR]")
    muted_text = Esc.style() |> Esc.theme_foreground(:muted)

    IO.puts("    #{info} " <> Esc.render(muted_text, "Application started successfully"))
    IO.puts("    #{warn} " <> Esc.render(muted_text, "Configuration file not found, using defaults"))
    IO.puts("    #{err} " <> Esc.render(muted_text, "Failed to connect to database"))

    # Progress indicator
    IO.puts("")
    IO.puts("  Progress:")
    filled = Esc.style() |> Esc.background(Esc.theme_color(:success)) |> Esc.render(String.duplicate(" ", 24))
    empty = Esc.style() |> Esc.background(theme.ansi_8) |> Esc.render(String.duplicate(" ", 16))
    pct = Esc.style() |> Esc.theme_foreground(:success) |> Esc.bold() |> Esc.render("60%")
    IO.puts("    #{filled}#{empty} #{pct}")

    # Code block
    IO.puts("")
    IO.puts("  Code snippet:")
    code_bg = Esc.style() |> Esc.background(theme.ansi_0) |> Esc.foreground(theme.foreground)
    keyword = Esc.style() |> Esc.background(theme.ansi_0) |> Esc.foreground(theme.ansi_5)
    func = Esc.style() |> Esc.background(theme.ansi_0) |> Esc.foreground(theme.ansi_4)
    string = Esc.style() |> Esc.background(theme.ansi_0) |> Esc.foreground(theme.ansi_2)
    comment = Esc.style() |> Esc.background(theme.ansi_0) |> Esc.foreground(theme.ansi_8)

    IO.puts("    " <> Esc.render(code_bg, "                                        "))
    IO.puts("    " <> Esc.render(keyword, "  def ") <> Esc.render(func, "hello") <> Esc.render(code_bg, " do                       "))
    IO.puts("    " <> Esc.render(code_bg, "    IO.puts ") <> Esc.render(string, "\"Hello, World!\"") <> Esc.render(code_bg, "          "))
    IO.puts("    " <> Esc.render(keyword, "  end") <> Esc.render(code_bg, " ") <> Esc.render(comment, "# greeting function") <> Esc.render(code_bg, "        "))
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
