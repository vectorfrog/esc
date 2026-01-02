# Run with: mix run examples/select_table_demo.exs

alias Esc.SelectTable

# Set theme for beautiful defaults
Esc.set_theme(:dracula)
theme = Esc.get_theme()

header_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :header)) |> Esc.bold()
muted_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))
success_style = Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :success)) |> Esc.bold()

IO.puts(Esc.render(header_style, "━━━ Esc SelectTable Demo ━━━"))
IO.puts(Esc.render(muted_style, "Theme: dracula │ hjkl/arrows/Tab: navigate │ Enter: select │ q: cancel"))
IO.puts("")

# Demo 1: Default styling with theme
IO.puts(Esc.render(header_style, "1. Default Theme Styling"))
IO.puts(Esc.render(muted_style, "   Cursor highlighted with theme's header color"))
IO.puts("")

colors = ~w(red orange yellow green blue indigo violet pink brown gray white black cyan magenta lime teal)

case SelectTable.new(colors) |> SelectTable.run() do
  {:ok, color} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{color}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 2: Custom cursor style - pink background
IO.puts(Esc.render(header_style, "2. Custom Cursor Style"))
IO.puts(Esc.render(muted_style, "   Pink background with white text"))
IO.puts("")

custom_cursor = Esc.style() |> Esc.background({255, 85, 184}) |> Esc.foreground(:white) |> Esc.bold()

files = [
  {"README.md", :readme},
  {"LICENSE", :license},
  {"mix.exs", :mix},
  {"lib/", :lib},
  {"test/", :test},
  {"config/", :config}
]

case SelectTable.new(files)
     |> SelectTable.cursor_style(custom_cursor)
     |> SelectTable.run() do
  {:ok, file} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{file}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 3: Custom item style too
IO.puts(Esc.render(header_style, "3. Custom Item & Cursor Styles"))
IO.puts(Esc.render(muted_style, "   Dim items, bright cyan cursor"))
IO.puts("")

dim_style = Esc.style() |> Esc.foreground({100, 100, 100})
bright_cursor = Esc.style() |> Esc.foreground({0, 255, 255}) |> Esc.bold()

emojis = ~w(😀 😎 🎉 🚀 💡 ⭐ 🔥 💪 🎯 🌟 💎 🏆 🌈 🎨 🎭 🎪)

case SelectTable.new(emojis)
     |> SelectTable.cursor_style(bright_cursor)
     |> SelectTable.item_style(dim_style)
     |> SelectTable.run() do
  {:ok, emoji} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{emoji}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 4: Different border styles
IO.puts(Esc.render(header_style, "4. Border Styles"))
IO.puts(Esc.render(muted_style, "   Double border with green cursor"))
IO.puts("")

green_cursor = Esc.style() |> Esc.foreground({80, 250, 123}) |> Esc.bold()

options = ~w(Option-A Option-B Option-C Option-D Option-E Option-F)

case SelectTable.new(options)
     |> SelectTable.border(:double)
     |> SelectTable.cursor_style(green_cursor)
     |> SelectTable.run() do
  {:ok, opt} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{opt}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 5: No border, minimal style
IO.puts(Esc.render(header_style, "5. No Border (Minimal)"))
IO.puts(Esc.render(muted_style, "   Clean look with underline cursor"))
IO.puts("")

underline_cursor = Esc.style() |> Esc.foreground({255, 184, 108}) |> Esc.underline() |> Esc.bold()

days = ~w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

case SelectTable.new(days)
     |> SelectTable.border(nil)
     |> SelectTable.cursor_style(underline_cursor)
     |> SelectTable.show_help(false)
     |> SelectTable.run() do
  {:ok, day} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{day}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")

# Demo 6: Fixed column count
IO.puts(Esc.render(header_style, "6. Fixed 3 Columns"))
IO.puts(Esc.render(muted_style, "   Force specific column layout"))
IO.puts("")

numbers = Enum.map(1..12, &"Item #{&1}")

case SelectTable.new(numbers)
     |> SelectTable.columns(3)
     |> SelectTable.run() do
  {:ok, num} -> IO.puts(Esc.render(success_style, "   ✓ Selected: #{num}"))
  :cancelled -> IO.puts(Esc.render(muted_style, "   ⨯ Cancelled"))
end

IO.puts("")
IO.puts(Esc.render(header_style, "━━━ Demo Complete ━━━"))
