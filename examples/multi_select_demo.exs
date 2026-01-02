# Multi-Select Demo
# Run with: mix run examples/multi_select_demo.exs [theme]
# Available themes: dracula, nord, gruvbox, monokai, solarized, github, aura, material

alias Esc.MultiSelect
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

warning = fn text ->
  style()
  |> foreground(Esc.theme_color(:warning))
  |> render(text)
end

# Title
IO.puts("")
IO.puts(header.("━━━ Esc Multi-Select Demo ━━━"))
IO.puts(subheader.("Theme: #{theme} │ ↑↓/jk navigate │ Space toggle │ Enter confirm │ q cancel"))
IO.puts(subheader.("Extra: a select all │ n clear all │ g/G jump first/last"))
IO.puts("")

# 1. Basic Multi-Select - Project Features
IO.puts(header.("Select project features"))
IO.puts("")

features = [
  {"Authentication", :auth},
  {"Database (Ecto)", :database},
  {"API endpoints", :api},
  {"WebSocket support", :websocket},
  {"Background jobs", :jobs},
  {"Email notifications", :email}
]

case MultiSelect.new(features)
     |> MultiSelect.cursor("❯ ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    if length(selected) > 0 do
      IO.puts(success.("✓ Features: #{Enum.join(Enum.map(selected, &to_string/1), ", ")}"))
    else
      IO.puts(subheader.("No features selected"))
    end
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 2. With Pre-selection and Minimum
IO.puts(header.("Configure deployment targets (min 1 required)"))
IO.puts("")

targets = [
  {"Production", :prod},
  {"Staging", :staging},
  {"Development", :dev},
  {"Local", :local}
]

case MultiSelect.new(targets)
     |> MultiSelect.preselect([:dev])
     |> MultiSelect.min_selections(1)
     |> MultiSelect.cursor("→ ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    IO.puts(success.("✓ Targets: #{Enum.join(Enum.map(selected, &to_string/1), ", ")}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 3. With Maximum Selection Limit
IO.puts(header.("Choose up to 3 toppings"))
IO.puts("")

toppings = [
  "Pepperoni",
  "Mushrooms",
  "Onions",
  "Sausage",
  "Bell Peppers",
  "Olives",
  "Jalapeños",
  "Pineapple"
]

case MultiSelect.new(toppings)
     |> MultiSelect.max_selections(3)
     |> MultiSelect.markers("● ", "○ ")
     |> MultiSelect.cursor("› ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    if length(selected) > 0 do
      IO.puts(success.("✓ Toppings: #{Enum.join(selected, ", ")}"))
    else
      IO.puts(subheader.("No toppings (plain cheese it is!)"))
    end
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 4. Custom Markers - File Selection
IO.puts(header.("Select files to delete"))
IO.puts(warning.("  (use 'a' to select all, 'n' to clear)"))
IO.puts("")

files = [
  {"node_modules/", :node_modules},
  {"_build/", :build},
  {"deps/", :deps},
  {".elixir_ls/", :elixir_ls},
  {"cover/", :cover},
  {"tmp/", :tmp}
]

case MultiSelect.new(files)
     |> MultiSelect.markers("[x] ", "[ ] ")
     |> MultiSelect.cursor("> ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    if length(selected) > 0 do
      IO.puts(warning.("! Would delete: #{Enum.join(Enum.map(selected, &to_string/1), ", ")}"))
    else
      IO.puts(success.("✓ Nothing selected, files are safe"))
    end
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 5. Styled Selection - Color Picker
IO.puts(header.("Pick your favorite colors"))
IO.puts("")

colors = [
  {"Red", :red},
  {"Green", :green},
  {"Blue", :blue},
  {"Yellow", :yellow},
  {"Purple", :purple},
  {"Cyan", :cyan}
]

case MultiSelect.new(colors)
     |> MultiSelect.markers("★ ", "☆ ")
     |> MultiSelect.cursor("» ")
     |> MultiSelect.min_selections(1)
     |> MultiSelect.max_selections(3)
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    IO.puts(success.("✓ Favorites: #{Enum.join(Enum.map(selected, &to_string/1), ", ")}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 6. No Help Text - Clean Look
IO.puts(header.("Quick selection (no help text)"))
IO.puts("")

options = ["Option A", "Option B", "Option C"]

case MultiSelect.new(options)
     |> MultiSelect.show_help(false)
     |> MultiSelect.markers("◉ ", "◯ ")
     |> MultiSelect.cursor("› ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{inspect(selected)}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

IO.puts(subheader.("━━━ Demo Complete ━━━"))
IO.puts("")
