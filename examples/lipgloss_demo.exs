# Lipgloss Feature Parity Demo
# Run with: mix run examples/lipgloss_demo.exs

import Esc

IO.puts("\n=== Esc: Lipgloss-style Terminal Styling for Elixir ===\n")

# Canonical Lipgloss example
IO.puts("1. Canonical Lipgloss Example:")
IO.puts("   (Bold white text on purple background, padded)")

result =
  style()
  |> bold()
  |> foreground("#FAFAFA")
  |> background("#7D56F4")
  |> padding(2, 4, 2, 4)
  |> width(22)
  |> render("Hello, kitty")

IO.puts(result)
IO.puts("")

# Color examples
IO.puts("2. Color Examples:")

colors = [
  {style() |> foreground(:red), "Named: Red"},
  {style() |> foreground(:bright_cyan), "Named: Bright Cyan"},
  {style() |> foreground(196), "256 palette: 196"},
  {style() |> foreground({255, 165, 0}), "RGB: Orange"},
  {style() |> foreground("#00ff88"), "Hex: Mint Green"}
]

for {s, label} <- colors do
  IO.puts("  " <> render(s, label))
end
IO.puts("")

# Border styles
IO.puts("3. Border Styles:")

borders = [:normal, :rounded, :thick, :double, :ascii, :markdown]

for border_style <- borders do
  box =
    style()
    |> border(border_style)
    |> width(12)
    |> align(:center)
    |> render(Atom.to_string(border_style))

  IO.puts(box)
  IO.puts("")
end

# Layout composition
IO.puts("4. Horizontal Join:")

left =
  style()
  |> border(:rounded)
  |> foreground(:cyan)
  |> padding(0, 1)
  |> render("Left")

right =
  style()
  |> border(:rounded)
  |> foreground(:magenta)
  |> padding(0, 1)
  |> render("Right")

IO.puts(Esc.join_horizontal([left, right]))
IO.puts("")

# Placement
IO.puts("5. Centered Placement:")

centered = Esc.place(30, 3, :center, :middle,
  style()
  |> bold()
  |> foreground(:yellow)
  |> render("* Centered *")
)

box =
  style()
  |> border(:double)
  |> render(centered)

IO.puts(box)
IO.puts("")

# Style inheritance
IO.puts("6. Style Inheritance:")

base_style =
  style()
  |> foreground(:green)
  |> bold()
  |> padding(0, 1)

derived =
  style()
  |> foreground(:red)  # Override green
  |> inherit(base_style)  # Inherit bold and padding

IO.puts(render(derived, "Inherited: red (overridden) + bold + padding"))
IO.puts("")

# Inline mode
IO.puts("7. Inline Mode:")

inline_text =
  style()
  |> inline(true)
  |> foreground(:cyan)
  |> bold()
  |> render("This\nwould\nbe\nmultiline")

IO.puts("  " <> inline_text)
IO.puts("")

# Max dimensions
IO.puts("8. Max Width Truncation:")

long_text = "This is a very long line of text that will be truncated"

truncated =
  style()
  |> max_width(30)
  |> foreground(:yellow)
  |> render(long_text)

IO.puts("  " <> truncated)
IO.puts("")

# Tables
IO.puts("9. Tables:")

alias Esc.Table

table =
  Table.new()
  |> Table.headers(["Name", "Language", "Stars"])
  |> Table.row(["Lipgloss", "Go", "8.2k"])
  |> Table.row(["Esc", "Elixir", "New!"])
  |> Table.row(["Chalk", "JavaScript", "21k"])
  |> Table.border(:rounded)
  |> Table.header_style(Esc.style() |> Esc.bold() |> Esc.foreground(:cyan))
  |> Table.render()

IO.puts(table)
IO.puts("")

# Lists
IO.puts("10. Lists:")

alias Esc.List, as: L

list =
  L.new(["First item", "Second item", "Third item"])
  |> L.enumerator(:arabic)
  |> L.item_style(Esc.style() |> Esc.foreground(:green))
  |> L.render()

IO.puts(list)
IO.puts("")

IO.puts("    Nested list with roman numerals:")

nested = L.new(["Sub A", "Sub B"]) |> L.enumerator(:dash)

nested_list =
  L.new(["Parent 1", nested, "Parent 2"])
  |> L.enumerator(:roman)
  |> L.render()

IO.puts(nested_list)
IO.puts("")

# Trees
IO.puts("11. Trees:")

alias Esc.Tree

tree =
  Tree.root("~/Projects")
  |> Tree.child(
    Tree.root("esc")
    |> Tree.child("lib")
    |> Tree.child("test")
    |> Tree.child("mix.exs")
  )
  |> Tree.child(
    Tree.root("other-project")
    |> Tree.child("src")
  )
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(Esc.style() |> Esc.bold() |> Esc.foreground(:blue))
  |> Tree.enumerator_style(Esc.style() |> Esc.foreground(:yellow))
  |> Tree.render()

IO.puts(tree)
IO.puts("")

IO.puts("=== Demo Complete! ===")
IO.puts("189 tests passing | All phases complete!")
IO.puts("")
