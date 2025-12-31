# Table Styles Demo
# Run with: mix run examples/table_demo.exs

alias Esc.Table
import Esc

IO.puts("\n=== Esc Table Styles Demo ===\n")

# Sample data
headers = ["Name", "Role", "Status"]
rows = [
  ["Alice", "Engineer", "Active"],
  ["Bob", "Designer", "Away"],
  ["Carol", "Manager", "Active"]
]

# 1. All border styles
IO.puts("1. Border Styles:\n")

border_styles = [:normal, :rounded, :thick, :double, :ascii, :markdown]

for border_style <- border_styles do
  IO.puts("   #{border_style}:")

  table =
    Table.new()
    |> Table.headers(headers)
    |> Table.rows(rows)
    |> Table.border(border_style)
    |> Table.render()

  table
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 2. No border
IO.puts("2. No Border (plain text):\n")

table =
  Table.new()
  |> Table.headers(headers)
  |> Table.rows(rows)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 3. Styled headers
IO.puts("3. Styled Headers:\n")

header_styles = [
  {"Bold cyan", style() |> bold() |> foreground(:cyan)},
  {"Yellow on blue", style() |> foreground(:yellow) |> background(:blue)},
  {"Underlined magenta", style() |> underline() |> foreground(:magenta)}
]

for {label, header_style} <- header_styles do
  IO.puts("   #{label}:")

  table =
    Table.new()
    |> Table.headers(headers)
    |> Table.rows(rows)
    |> Table.border(:rounded)
    |> Table.header_style(header_style)
    |> Table.render()

  table
  |> String.split("\n")
  |> Enum.each(&IO.puts("   #{&1}"))

  IO.puts("")
end

# 4. Styled rows
IO.puts("4. Styled Rows:\n")

table =
  Table.new()
  |> Table.headers(headers)
  |> Table.rows(rows)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:white))
  |> Table.row_style(style() |> foreground(:green))
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 5. Per-cell styling with style_func
IO.puts("5. Per-Cell Styling (alternating row colors):\n")

alternating_style = fn row, _col ->
  if rem(row, 2) == 0 do
    style() |> foreground(:cyan)
  else
    style() |> foreground(:yellow)
  end
end

table =
  Table.new()
  |> Table.headers(headers)
  |> Table.rows(rows)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold())
  |> Table.style_func(alternating_style)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 6. Column widths
IO.puts("6. Custom Column Widths:\n")

table =
  Table.new()
  |> Table.headers(["ID", "Description", "Price"])
  |> Table.row(["1", "Widget", "$10"])
  |> Table.row(["2", "Gadget", "$25"])
  |> Table.row(["3", "Gizmo", "$15"])
  |> Table.border(:rounded)
  |> Table.width(0, 5)   # ID column min 5 chars
  |> Table.width(1, 20)  # Description column min 20 chars
  |> Table.width(2, 10)  # Price column min 10 chars
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 7. Status indicators with conditional styling
IO.puts("7. Status Indicators:\n")

status_data = [
  ["web-server", "Running", "2.3%"],
  ["database", "Stopped", "0%"],
  ["cache", "Running", "15.7%"],
  ["worker", "Error", "0%"]
]

status_style = fn row, col ->
  if col == 1 do
    status = Enum.at(status_data, row) |> Enum.at(1)

    case status do
      "Running" -> style() |> foreground(:green)
      "Stopped" -> style() |> foreground(:yellow)
      "Error" -> style() |> foreground(:red) |> bold()
      _ -> style()
    end
  else
    style()
  end
end

table =
  Table.new()
  |> Table.headers(["Service", "Status", "CPU"])
  |> Table.rows(status_data)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:cyan))
  |> Table.style_func(status_style)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 8. Compact data table
IO.puts("8. Compact Data Display:\n")

compact_data = [
  ["Users", "1,234"],
  ["Sessions", "567"],
  ["Requests/s", "89.2"],
  ["Errors", "3"]
]

table =
  Table.new()
  |> Table.rows(compact_data)
  |> Table.border(:rounded)
  |> Table.row_style(style() |> foreground(:white))
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
