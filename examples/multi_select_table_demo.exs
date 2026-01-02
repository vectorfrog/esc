# Run with: mix run examples/multi_select_table_demo.exs

alias Esc.MultiSelectTable

# Set theme for beautiful defaults
Esc.set_theme(:dracula)
theme = Esc.get_theme()

header_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :header)) |> Esc.bold()
muted_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))
success_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :success)) |> Esc.bold()

IO.puts(Esc.render(header_style, "━━━ Esc MultiSelectTable Demo ━━━"))
IO.puts(Esc.render(muted_style, "Theme: dracula │ hjkl/arrows/Tab: nav │ Space: toggle │ Enter: confirm │ q: cancel"))
IO.puts(Esc.render(muted_style, "Extra: a: select all │ n: clear all"))
IO.puts("")

# Demo 1: Default styling with theme
IO.puts(Esc.render(header_style, "1. Default Theme Styling"))
IO.puts(Esc.render(muted_style, "   Cursor=cyan, Selected=green (from theme)"))
IO.puts("")

tags = ~w(elixir phoenix ecto liveview tailwind alpine docker kubernetes aws gcp postgres redis graphql rest)

case MultiSelectTable.new(tags) |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 2: Custom markers
IO.puts(Esc.render(header_style, "2. Custom Selection Markers"))
IO.puts(Esc.render(muted_style, "   Using ✓ instead of * for selected items"))
IO.puts("")

languages = ~w(JavaScript TypeScript Python Ruby Go Rust Elixir Java C++ Swift)

case MultiSelectTable.new(languages)
     |> MultiSelectTable.selected_marker("✓")
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 3: Custom cursor and selected styles
IO.puts(Esc.render(header_style, "3. Custom Cursor & Selected Styles"))
IO.puts(Esc.render(muted_style, "   Yellow cursor, magenta selected items"))
IO.puts("")

yellow_cursor = Esc.style() |> Esc.foreground({255, 255, 0}) |> Esc.bold()
magenta_selected = Esc.style() |> Esc.foreground({255, 85, 184}) |> Esc.bold()

fruits = ~w(Apple Banana Cherry Date Elderberry Fig Grape Honeydew Kiwi Lemon Mango Nectarine)

case MultiSelectTable.new(fruits)
     |> MultiSelectTable.cursor_style(yellow_cursor)
     |> MultiSelectTable.selected_style(magenta_selected)
     |> MultiSelectTable.selected_marker("●")
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 4: With min/max constraints
IO.puts(Esc.render(header_style, "4. Selection Constraints"))
IO.puts(Esc.render(muted_style, "   min: 2, max: 4 selections required"))
IO.puts("")

files = ~w(file1.txt file2.txt file3.txt file4.txt file5.txt file6.txt data.json config.yaml readme.md)

case MultiSelectTable.new(files)
     |> MultiSelectTable.min_selections(2)
     |> MultiSelectTable.max_selections(4)
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 5: Different border style + dim unselected items
IO.puts(Esc.render(header_style, "5. Thick Border + Dim Unselected"))
IO.puts(Esc.render(muted_style, "   Unselected items are dimmed for focus"))
IO.puts("")

dim_item = Esc.style() |> Esc.foreground({80, 80, 80})
bright_cursor = Esc.style() |> Esc.foreground({139, 233, 253}) |> Esc.bold()
green_selected = Esc.style() |> Esc.foreground({80, 250, 123}) |> Esc.bold()

tools = ~w(VSCode Neovim Emacs Sublime Atom Zed Helix)

case MultiSelectTable.new(tools)
     |> MultiSelectTable.border(:thick)
     |> MultiSelectTable.cursor_style(bright_cursor)
     |> MultiSelectTable.selected_style(green_selected)
     |> MultiSelectTable.item_style(dim_item)
     |> MultiSelectTable.selected_marker("→")
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 6: Pre-selected items
IO.puts(Esc.render(header_style, "6. Pre-selected Items"))
IO.puts(Esc.render(muted_style, "   Some items are selected by default"))
IO.puts("")

features = ~w(auth routing database caching logging metrics testing deployment)

case MultiSelectTable.new(features)
     |> MultiSelectTable.preselect(["auth", "database", "logging"])
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 7: No border, emoji markers
IO.puts(Esc.render(header_style, "7. No Border + Emoji Markers"))
IO.puts(Esc.render(muted_style, "   Minimal look with fun emoji markers"))
IO.puts("")

orange_cursor = Esc.style() |> Esc.foreground({255, 184, 108}) |> Esc.bold()
blue_selected = Esc.style() |> Esc.foreground({98, 114, 164})

sizes = ~w(XS S M L XL XXL)

case MultiSelectTable.new(sizes)
     |> MultiSelectTable.border(nil)
     |> MultiSelectTable.cursor_style(orange_cursor)
     |> MultiSelectTable.selected_style(blue_selected)
     |> MultiSelectTable.selected_marker("✔")
     |> MultiSelectTable.show_help(false)
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts(Esc.render(success_style, "   ✓ Selected: #{Enum.join(selected, ", ")}"))
  :cancelled ->
    IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")
IO.puts(Esc.render(header_style, "━━━ Demo Complete ━━━"))
