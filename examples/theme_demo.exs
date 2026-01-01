#!/usr/bin/env elixir
# Theme demo script - run with: mix run examples/theme_demo.exs

alias Esc.{Table, Tree, List}

# Helper to print section headers
defmodule Demo do
  def section(title) do
    IO.puts("\n" <> String.duplicate("═", 60))
    IO.puts("  #{title}")
    IO.puts(String.duplicate("═", 60) <> "\n")
  end

  def theme_preview(name) do
    Esc.set_theme(name)
    theme = Esc.get_theme()

    IO.puts("Theme: #{name}")
    IO.puts(String.duplicate("─", 40))

    # Show color palette
    colors = [
      {:error, "Error"},
      {:warning, "Warning"},
      {:success, "Success"},
      {:header, "Header"},
      {:emphasis, "Emphasis"},
      {:muted, "Muted"}
    ]

    for {semantic, label} <- colors do
      color = Esc.Theme.color(theme, semantic)
      text = Esc.style() |> Esc.foreground(color) |> Esc.render(String.pad_trailing(label, 12))
      IO.write(text)
    end
    IO.puts("")

    # Show a sample table
    Table.new()
    |> Table.headers(["Status", "Count"])
    |> Table.row(["Active", "42"])
    |> Table.row(["Pending", "17"])
    |> Table.border(:rounded)
    |> Table.render()
    |> IO.puts()

    IO.puts("")
  end
end

Demo.section("Theme Feature Demo")

IO.puts("""
Esc now supports 12 built-in themes from popular terminal color schemes.
Set a theme with: Esc.set_theme(:theme_name)

Available themes: #{Enum.join(Esc.themes(), ", ")}
""")

Demo.section("Theme Previews")

# Show previews of a few themes
for theme <- [:nord, :dracula, :gruvbox, :monokai] do
  Demo.theme_preview(theme)
end

Demo.section("Semantic Colors")

Esc.set_theme(:nord)

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
    Esc.style()
    |> Esc.theme_foreground(semantic)
    |> Esc.bold()
    |> Esc.render(String.pad_trailing(":#{semantic}", 12))

  IO.puts("  #{label} - #{desc}")
end

Demo.section("Auto-Themed Components")

Esc.set_theme(:dracula)
IO.puts("With Esc.set_theme(:dracula), components automatically use theme colors:\n")

IO.puts("Table (headers use :header, borders use :muted):")
Table.new()
|> Table.headers(["Feature", "Status", "Priority"])
|> Table.row(["Theme support", "Complete", "High"])
|> Table.row(["Auto-theming", "Complete", "High"])
|> Table.row(["12 themes", "Complete", "Medium"])
|> Table.border(:rounded)
|> Table.render()
|> IO.puts()

IO.puts("\nTree (root uses :emphasis, connectors use :muted):")
Tree.root("Project")
|> Tree.child("lib")
|> Tree.child("test")
|> Tree.child("examples")
|> Tree.render()
|> IO.puts()

IO.puts("\nList (enumerators use :muted):")
List.new(["First item", "Second item", "Third item"])
|> List.enumerator(:arabic)
|> List.render()
|> IO.puts()

Demo.section("Disabling Theme for Specific Components")

IO.puts("Use .use_theme(false) to disable auto-theming:\n")

IO.puts("Without theme:")
Table.new()
|> Table.use_theme(false)
|> Table.headers(["Column A", "Column B"])
|> Table.row(["Value 1", "Value 2"])
|> Table.border(:rounded)
|> Table.render()
|> IO.puts()

IO.puts("\nWith theme:")
Table.new()
|> Table.headers(["Column A", "Column B"])
|> Table.row(["Value 1", "Value 2"])
|> Table.border(:rounded)
|> Table.render()
|> IO.puts()

Demo.section("Direct Theme Color Access")

IO.puts("Access theme colors directly with Esc.theme_color/1:\n")

Esc.set_theme(:nord)
IO.puts("  Esc.theme_color(:error)   => #{inspect(Esc.theme_color(:error))}")
IO.puts("  Esc.theme_color(:success) => #{inspect(Esc.theme_color(:success))}")
IO.puts("  Esc.theme_color(:header)  => #{inspect(Esc.theme_color(:header))}")

Demo.section("All 12 Themes")

IO.puts("Quick preview of all available themes:\n")

for theme <- Esc.themes() do
  Esc.set_theme(theme)
  t = Esc.get_theme()

  name = String.pad_trailing("#{theme}", 12)
  sample =
    Esc.style()
    |> Esc.foreground(t.foreground)
    |> Esc.background(t.background)
    |> Esc.render(" #{name} ")

  colors = for i <- 0..7 do
    color = Map.get(t, :"ansi_#{i}")
    Esc.style() |> Esc.foreground(color) |> Esc.render("●")
  end

  IO.puts("  #{sample}  #{Enum.join(colors, " ")}")
end

IO.puts("\n")
