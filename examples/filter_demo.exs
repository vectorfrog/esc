# Filter Demo
# Run with: mix run examples/filter_demo.exs [theme]
# Available themes: dracula, nord, gruvbox, monokai, solarized, github, aura, material
#
# Demonstrates the filter feature across all select components.
# Press "/" to enter filter mode, type to filter, Escape to exit filter mode.
# Supports glob-style wildcards: *.md matches "readme.md"

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

# Title
IO.puts("")
IO.puts(header.("━━━ Esc Filter Demo ━━━"))
IO.puts(subheader.("Theme: #{theme} │ Press / to filter │ * for wildcards │ Escape to exit filter"))
IO.puts("")

# 1. Select with Filter - Programming Languages
IO.puts(header.("Select a programming language"))
IO.puts(subheader.("Try: type 'el' to filter, or '*pt' to match ending"))
IO.puts("")

languages = [
  {"Elixir", :elixir},
  {"Erlang", :erlang},
  {"Python", :python},
  {"Ruby", :ruby},
  {"Rust", :rust},
  {"Go", :go},
  {"JavaScript", :javascript},
  {"TypeScript", :typescript},
  {"C", :c},
  {"C++", :cpp},
  {"Haskell", :haskell},
  {"OCaml", :ocaml}
]

case Select.new(languages)
     |> Select.cursor("❯ ")
     |> Select.run() do
  {:ok, lang} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{lang}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 2. MultiSelect with Filter - File Selection
IO.puts(header.("Select files to include"))
IO.puts(subheader.("Try: '*.md' to filter markdown, '*.ex*' for Elixir files"))
IO.puts("")

files = [
  {"README.md", "readme"},
  {"LICENSE", "license"},
  {"mix.exs", "mix"},
  {"lib/app.ex", "app"},
  {"lib/app/server.ex", "server"},
  {"lib/app/client.ex", "client"},
  {"test/app_test.exs", "test_app"},
  {"test/server_test.exs", "test_server"},
  {"config/config.exs", "config"},
  {"CHANGELOG.md", "changelog"},
  {".gitignore", "gitignore"},
  {"Dockerfile", "docker"}
]

case MultiSelect.new(files)
     |> MultiSelect.cursor("❯ ")
     |> MultiSelect.run() do
  {:ok, selected} ->
    IO.puts("")
    IO.puts(success.("✓ Selected #{length(selected)} files: #{inspect(selected)}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 3. SelectTable with Filter - Country Selection
IO.puts(header.("Select a country"))
IO.puts(subheader.("Try: 'united' to filter, or 'j*' for J countries"))
IO.puts("")

countries = [
  {"United States", :us},
  {"United Kingdom", :uk},
  {"Canada", :ca},
  {"Australia", :au},
  {"Germany", :de},
  {"France", :fr},
  {"Japan", :jp},
  {"Brazil", :br},
  {"India", :in},
  {"China", :cn},
  {"Mexico", :mx},
  {"Italy", :it},
  {"Spain", :es},
  {"Netherlands", :nl},
  {"Sweden", :se},
  {"Norway", :no}
]

case SelectTable.new(countries)
     |> SelectTable.columns(4)
     |> SelectTable.run() do
  {:ok, country} ->
    IO.puts("")
    IO.puts(success.("✓ Selected: #{country}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

# 4. MultiSelectTable with Filter - Feature Flags
IO.puts(header.("Enable features"))
IO.puts(subheader.("Try: 'dark' or 'api*' to filter"))
IO.puts("")

features = [
  {"Dark Mode", :dark_mode},
  {"API Access", :api_access},
  {"API Rate Limiting", :api_rate_limit},
  {"Notifications", :notifications},
  {"Email Alerts", :email_alerts},
  {"Two-Factor Auth", :two_factor},
  {"SSO Login", :sso},
  {"Audit Logs", :audit_logs},
  {"Export Data", :export},
  {"Import Data", :import},
  {"Webhooks", :webhooks},
  {"Custom Themes", :custom_themes}
]

case MultiSelectTable.new(features)
     |> MultiSelectTable.columns(3)
     |> MultiSelectTable.run() do
  {:ok, selected} ->
    IO.puts("")
    IO.puts(success.("✓ Enabled #{length(selected)} features: #{inspect(selected)}"))
    IO.puts("")

  :cancelled ->
    IO.puts("")
    IO.puts(subheader.("⨯ Cancelled"))
    IO.puts("")
end

IO.puts(subheader.("━━━ Demo Complete ━━━"))
IO.puts("")
