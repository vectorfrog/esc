# Tree Styles Demo
# Run with: mix run examples/tree_demo.exs

alias Esc.Tree
import Esc

IO.puts("\n=== Esc Tree Styles Demo ===\n")

# 1. Enumerator styles
IO.puts("1. Enumerator Styles:\n")

IO.puts("   Default (└──):")
tree =
  Tree.root("project")
  |> Tree.child("src")
  |> Tree.child("lib")
  |> Tree.child("test")
  |> Tree.enumerator(:default)
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("   Rounded (╰──):")
tree =
  Tree.root("project")
  |> Tree.child("src")
  |> Tree.child("lib")
  |> Tree.child("test")
  |> Tree.enumerator(:rounded)
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 2. Root styling
IO.puts("2. Root Styling:\n")

root_styles = [
  {"Bold", style() |> bold()},
  {"Cyan", style() |> foreground(:cyan)},
  {"Bold yellow on blue", style() |> bold() |> foreground(:yellow) |> background(:blue)}
]

for {label, root_style} <- root_styles do
  IO.puts("   #{label}:")

  tree =
    Tree.root("~/Documents")
    |> Tree.child("notes.txt")
    |> Tree.child("todo.md")
    |> Tree.enumerator(:rounded)
    |> Tree.root_style(root_style)
    |> Tree.render()

  tree
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 3. Item styling
IO.puts("3. Item Styling:\n")

tree =
  Tree.root("Colors")
  |> Tree.child("Red file")
  |> Tree.child("Green file")
  |> Tree.child("Blue file")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:white))
  |> Tree.item_style(style() |> foreground(:green))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 4. Enumerator styling (connector colors)
IO.puts("4. Enumerator Styling (colored connectors):\n")

connector_styles = [
  {"Yellow connectors", style() |> foreground(:yellow)},
  {"Dim connectors", style() |> faint()},
  {"Cyan connectors", style() |> foreground(:cyan)}
]

for {label, enum_style} <- connector_styles do
  IO.puts("   #{label}:")

  tree =
    Tree.root("Root")
    |> Tree.child("Branch A")
    |> Tree.child("Branch B")
    |> Tree.child("Branch C")
    |> Tree.enumerator(:rounded)
    |> Tree.root_style(style() |> bold())
    |> Tree.enumerator_style(enum_style)
    |> Tree.render()

  tree
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 5. Nested trees
IO.puts("5. Nested Trees:\n")

subtree1 =
  Tree.root("src")
  |> Tree.child("main.ex")
  |> Tree.child("utils.ex")

subtree2 =
  Tree.root("test")
  |> Tree.child("main_test.exs")

tree =
  Tree.root("my_app")
  |> Tree.child(subtree1)
  |> Tree.child(subtree2)
  |> Tree.child("mix.exs")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:blue))
  |> Tree.item_style(style() |> foreground(:white))
  |> Tree.enumerator_style(style() |> foreground(:yellow))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 6. Deep nesting
IO.puts("6. Deep Nesting:\n")

deep_subtree =
  Tree.root("deeply")
  |> Tree.child(
    Tree.root("nested")
    |> Tree.child(
      Tree.root("structure")
      |> Tree.child("leaf.txt")
    )
  )

tree =
  Tree.root("root")
  |> Tree.child(deep_subtree)
  |> Tree.child("sibling")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold())
  |> Tree.enumerator_style(style() |> foreground(:cyan))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 7. File system style
IO.puts("7. File System Style:\n")

lib =
  Tree.root("lib/")
  |> Tree.child("esc.ex")
  |> Tree.child(
    Tree.root("esc/")
    |> Tree.child("border.ex")
    |> Tree.child("color.ex")
    |> Tree.child("style.ex")
    |> Tree.child("table.ex")
    |> Tree.child("tree.ex")
  )

test =
  Tree.root("test/")
  |> Tree.child("esc_test.exs")
  |> Tree.child("test_helper.exs")

tree =
  Tree.root("esc/")
  |> Tree.child(lib)
  |> Tree.child(test)
  |> Tree.child("mix.exs")
  |> Tree.child("README.md")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:blue))
  |> Tree.item_style(style() |> foreground(:white))
  |> Tree.enumerator_style(style() |> faint())
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 8. Combined styling showcase
IO.puts("8. Full Styling Showcase:\n")

apps =
  Tree.root("Applications")
  |> Tree.child("Terminal")
  |> Tree.child("Editor")
  |> Tree.child("Browser")

docs =
  Tree.root("Documents")
  |> Tree.child("Projects")
  |> Tree.child("Notes")

tree =
  Tree.root("~")
  |> Tree.child(apps)
  |> Tree.child(docs)
  |> Tree.child(".config")
  |> Tree.enumerator(:rounded)
  |> Tree.root_style(style() |> bold() |> foreground(:magenta))
  |> Tree.item_style(style() |> foreground(:green))
  |> Tree.enumerator_style(style() |> foreground(:yellow))
  |> Tree.render()

tree
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
