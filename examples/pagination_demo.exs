# Pagination Demo
# Run with: mix run examples/pagination_demo.exs [theme]
# Available themes: dracula, nord, gruvbox, monokai, solarized, github, aura, material

alias Esc.{Select, MultiSelect, SelectTable, MultiSelectTable}
import Esc

# Parse theme from command line args, default to :dracula
theme =
  case System.argv() do
    [theme_name | _] -> String.to_atom(theme_name)
    _ -> :dracula
  end

# Set the theme
Esc.set_theme(theme)

# Helper to render styled headers
header = fn text ->
  style()
  |> foreground(Esc.theme_color(:header))
  |> bold()
  |> render(text)
end

subheader = fn text ->
  style()
  |> foreground(Esc.theme_color(:muted))
  |> render(text)
end

success = fn text ->
  style()
  |> foreground(Esc.theme_color(:success))
  |> bold()
  |> render(text)
end

# Generate 250 items for demonstration
items = for i <- 1..250, do: {"Item #{String.pad_leading("#{i}", 3, "0")}", i}

# Title
IO.puts("")
IO.puts(header.("━━━ Esc Pagination Demo ━━━"))
IO.puts(subheader.("Theme: #{theme} │ ]/[ or Ctrl+F/B for page nav │ / to filter"))
IO.puts("")

# 1. Select with pagination (10 items per page for demo)
IO.puts(header.("1. Select with Pagination (10 per page)"))
IO.puts(subheader.("Navigate with j/k, change pages with ]/[ or Ctrl+F/B"))
IO.puts("")

case Select.new(items)
     |> Select.page_size(10)
     |> Select.cursor("→ ")
     |> Select.run() do
  {:ok, value} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{value}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 2. MultiSelect with pagination
IO.puts(header.("2. MultiSelect with Pagination (15 per page)"))
IO.puts(subheader.("Space to toggle, a/n to select all/none visible"))
IO.puts("")

case MultiSelect.new(items)
     |> MultiSelect.page_size(15)
     |> MultiSelect.show_help(true)
     |> MultiSelect.run() do
  {:ok, values} ->
    IO.puts("")
    IO.puts(success.("✓ Selected #{length(values)} items: #{inspect(Enum.take(values, 5))}#{if length(values) > 5, do: "...", else: ""}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 3. SelectTable with pagination (smaller set for grid)
table_items = for i <- 1..100, do: {"Item #{i}", i}

IO.puts(header.("3. SelectTable with Pagination (20 per page)"))
IO.puts(subheader.("Grid navigation with h/j/k/l or arrows"))
IO.puts("")

case SelectTable.new(table_items)
     |> SelectTable.page_size(20)
     |> SelectTable.run() do
  {:ok, value} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{value}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 4. MultiSelectTable with pagination
IO.puts(header.("4. MultiSelectTable with Pagination (25 per page)"))
IO.puts(subheader.("Space to toggle, grid navigation"))
IO.puts("")

case MultiSelectTable.new(table_items)
     |> MultiSelectTable.page_size(25)
     |> MultiSelectTable.run() do
  {:ok, values} ->
    IO.puts("")
    IO.puts(success.("✓ Selected #{length(values)} items"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 5. Pagination with filter
IO.puts(header.("5. Select with Filter + Pagination"))
IO.puts(subheader.("Press / to filter, pagination adjusts to filtered results"))
IO.puts("")

# Generate items with varied names for better filtering demo
filter_items =
  ~w(apple apricot avocado banana blueberry cherry cranberry date elderberry fig grape guava honeydew kiwi lemon lime mango melon nectarine orange papaya peach pear plum pomegranate quince raspberry strawberry tangerine watermelon)
  |> Enum.with_index(1)
  |> Enum.flat_map(fn {fruit, i} ->
    for j <- 1..5, do: {"#{fruit}_#{j}", {fruit, i, j}}
  end)

case Select.new(filter_items)
     |> Select.page_size(12)
     |> Select.cursor("❯ ")
     |> Select.run() do
  {:ok, value} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{inspect(value)}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

IO.puts("")
IO.puts(subheader.("━━━ Demo Complete ━━━"))
IO.puts("")
