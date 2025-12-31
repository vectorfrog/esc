# List Styles Demo
# Run with: mix run examples/list_demo.exs

alias Esc.List
import Esc

IO.puts("\n=== Esc List Styles Demo ===\n")

# 1. Enumerator styles
IO.puts("1. Enumerator Styles:\n")

enumerators = [
  {:bullet, "Bullet (•)"},
  {:dash, "Dash (-)"},
  {:arabic, "Arabic (1., 2., 3.)"},
  {:roman, "Roman (i., ii., iii.)"},
  {:alphabet, "Alphabet (a., b., c.)"}
]

for {enum, label} <- enumerators do
  IO.puts("   #{label}:")

  list =
    List.new(["First item", "Second item", "Third item"])
    |> List.enumerator(enum)
    |> List.render()

  list
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 2. Styled enumerators
IO.puts("2. Styled Enumerators:\n")

IO.puts("   Cyan bullets:")
list =
  List.new(["Apple", "Banana", "Cherry"])
  |> List.enumerator(:bullet)
  |> List.enumerator_style(style() |> foreground(:cyan))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("   Yellow numbers:")
list =
  List.new(["First", "Second", "Third"])
  |> List.enumerator(:arabic)
  |> List.enumerator_style(style() |> foreground(:yellow) |> bold())
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 3. Styled items
IO.puts("3. Styled Items:\n")

list =
  List.new(["Important task", "Another task", "Final task"])
  |> List.enumerator(:bullet)
  |> List.enumerator_style(style() |> foreground(:green))
  |> List.item_style(style() |> foreground(:white))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 4. Custom enumerator function
IO.puts("4. Custom Enumerator (emoji):\n")

emoji_enum = fn idx ->
  emojis = ["🍎 ", "🍌 ", "🍒 ", "🍇 ", "🍊 "]
  Enum.at(emojis, rem(idx, length(emojis)))
end

list =
  List.new(["Apple", "Banana", "Cherry", "Grape", "Orange"])
  |> List.enumerator(emoji_enum)
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 5. Checkbox style
IO.puts("5. Checkbox Style:\n")

checkbox_enum = fn idx ->
  states = ["[x] ", "[ ] ", "[x] ", "[ ] ", "[~] "]
  Enum.at(states, rem(idx, length(states)))
end

list =
  List.new([
    "Complete project setup",
    "Write documentation",
    "Add unit tests",
    "Deploy to production",
    "In progress task"
  ])
  |> List.enumerator(checkbox_enum)
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 6. Nested lists
IO.puts("6. Nested Lists:\n")

sub_list1 =
  List.new(["Sub-item A", "Sub-item B"])
  |> List.enumerator(:dash)

sub_list2 =
  List.new(["Another sub", "And another"])
  |> List.enumerator(:dash)

list =
  List.new(["Main item 1", sub_list1, "Main item 2", sub_list2, "Main item 3"])
  |> List.enumerator(:arabic)
  |> List.enumerator_style(style() |> foreground(:cyan))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 7. Deep nesting
IO.puts("7. Deep Nesting:\n")

deep_sub =
  List.new(["Deeply nested item"])
  |> List.enumerator(:bullet)

mid_sub =
  List.new(["Mid-level item", deep_sub])
  |> List.enumerator(:dash)

list =
  List.new(["Top level", mid_sub, "Another top level"])
  |> List.enumerator(:arabic)
  |> List.enumerator_style(style() |> foreground(:yellow))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 8. Todo list style
IO.puts("8. Todo List:\n")

todo_enum = fn idx ->
  case idx do
    0 -> "✅ "
    1 -> "✅ "
    2 -> "⏳ "
    3 -> "❌ "
    _ -> "⬜ "
  end
end

list =
  List.new([
    "Setup development environment",
    "Create database schema",
    "Implement user authentication",
    "Write API documentation",
    "Deploy to staging"
  ])
  |> List.enumerator(todo_enum)
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 9. Shopping list
IO.puts("9. Shopping List:\n")

produce =
  List.new(["Apples", "Bananas", "Carrots"])
  |> List.enumerator(:bullet)

dairy =
  List.new(["Milk", "Cheese", "Yogurt"])
  |> List.enumerator(:bullet)

list =
  List.new(["🥬 Produce", produce, "🧀 Dairy", dairy])
  |> List.enumerator(:bullet)
  |> List.item_style(style() |> foreground(:green))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 10. Command menu
IO.puts("10. Command Menu:\n")

arrow_enum = fn _idx -> "→ " end

list =
  List.new([
    "new     Create a new project",
    "build   Build the project",
    "test    Run tests",
    "deploy  Deploy to production",
    "help    Show help message"
  ])
  |> List.enumerator(arrow_enum)
  |> List.enumerator_style(style() |> foreground(:cyan))
  |> List.item_style(style() |> foreground(:white))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 11. Ingredients list with quantities
IO.puts("11. Recipe Ingredients:\n")

list =
  List.new([
    "2 cups flour",
    "1 cup sugar",
    "3 eggs",
    "1/2 cup butter",
    "1 tsp vanilla extract"
  ])
  |> List.enumerator(:bullet)
  |> List.enumerator_style(style() |> foreground(:yellow))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 12. Changelog style
IO.puts("12. Changelog Style:\n")

added =
  List.new(["New dashboard feature", "API rate limiting"])
  |> List.enumerator(:bullet)

fixed =
  List.new(["Login timeout issue", "Memory leak in worker"])
  |> List.enumerator(:bullet)

list =
  List.new(["✨ Added", added, "🐛 Fixed", fixed])
  |> List.enumerator(:bullet)
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 13. Priority list
IO.puts("13. Priority List:\n")

priority_enum = fn idx ->
  case idx do
    0 -> "🔴 "
    1 -> "🟠 "
    2 -> "🟡 "
    _ -> "🟢 "
  end
end

list =
  List.new([
    "Critical security patch",
    "Performance optimization",
    "UI improvements",
    "Documentation updates"
  ])
  |> List.enumerator(priority_enum)
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 14. Steps/Instructions
IO.puts("14. Step-by-Step Instructions:\n")

step_enum = fn idx -> "Step #{idx + 1}: " end

list =
  List.new([
    "Clone the repository",
    "Install dependencies with mix deps.get",
    "Configure your database in config/dev.exs",
    "Run migrations with mix ecto.migrate",
    "Start the server with mix phx.server"
  ])
  |> List.enumerator(step_enum)
  |> List.enumerator_style(style() |> bold() |> foreground(:cyan))
  |> List.render()

list
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
