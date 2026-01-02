# Select Demo
# Run with: mix run examples/select_demo.exs [theme]
# Available themes: dracula, nord, gruvbox, monokai, solarized, github, aura, material

alias Esc.Select
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

# Title
IO.puts("")
IO.puts(header.("━━━ Esc Select Demo ━━━"))
IO.puts(subheader.("Theme: #{theme} │ ↑↓/jk navigate │ Enter select │ q cancel"))
IO.puts("")

# 1. Project Type Selection
IO.puts(header.("What type of project?"))
IO.puts("")

projects = [
  {"Web Application", :web},
  {"CLI Tool", :cli},
  {"Library", :lib},
  {"API Service", :api}
]

case Select.new(projects)
     |> Select.cursor("❯ ")
     |> Select.run() do
  {:ok, type} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{type}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 2. Framework Selection
IO.puts(header.("Choose a framework"))
IO.puts("")

frameworks = [
  {"Phoenix         Full-stack web framework", :phoenix},
  {"Plug            Minimal HTTP toolkit", :plug},
  {"Bandit          Pure Elixir HTTP server", :bandit},
  {"None            Start from scratch", :none}
]

case Select.new(frameworks)
     |> Select.cursor("→ ")
     |> Select.run() do
  {:ok, fw} ->
    IO.puts("")
    IO.puts(success.("✓ Framework: #{fw}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 3. Database Selection
IO.puts(header.("Select database"))
IO.puts("")

databases = [
  {"PostgreSQL", :postgres},
  {"SQLite", :sqlite},
  {"MySQL", :mysql},
  {"None", :none}
]

case Select.new(databases)
     |> Select.cursor("● ")
     |> Select.run() do
  {:ok, db} ->
    IO.puts("")
    IO.puts(success.("✓ Database: #{db}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Skipped"))
    IO.puts("")
end

# 4. Confirmation
IO.puts(header.("Ready to create project?"))
IO.puts("")

case Select.new([{"Yes, create it!", true}, {"No, cancel", false}])
     |> Select.cursor("◆ ")
     |> Select.run() do
  {:ok, true} ->
    IO.puts("")
    IO.puts(success.("✓ Project created successfully!"))

  {:ok, false} ->
    IO.puts("")
    IO.puts(subheader.("Project creation cancelled."))

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("Aborted."))
end

IO.puts("")
IO.puts(subheader.("━━━ Demo Complete ━━━"))
IO.puts("")
