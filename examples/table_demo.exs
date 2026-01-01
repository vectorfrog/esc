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

# 9. Right-aligned numeric data
IO.puts("9. Right-Aligned Numeric Data:\n")

financial_data = [
  ["Revenue", "Q1", "$1,234,567"],
  ["Revenue", "Q2", "$1,456,789"],
  ["Revenue", "Q3", "$1,678,901"],
  ["Revenue", "Q4", "$2,345,678"],
  ["Total", "", "$6,715,935"]
]

# Right-pad category, left-pad numbers for right alignment
financial_rows =
  financial_data
  |> Enum.map(fn [cat, period, amount] ->
    [cat, period, String.pad_leading(amount, 12)]
  end)

table =
  Table.new()
  |> Table.headers(["Category", "Period", "Amount"])
  |> Table.rows(financial_rows)
  |> Table.border(:double)
  |> Table.header_style(style() |> bold() |> foreground(:cyan))
  |> Table.style_func(fn row, _col ->
    if row == 4, do: style() |> bold() |> foreground(:green), else: style()
  end)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 10. Unicode/Emoji content
IO.puts("10. Unicode & Emoji Content:\n")

unicode_data = [
  ["🚀", "Deployment", "Completed"],
  ["⚠️", "Warning", "Low disk space"],
  ["✅", "Tests", "All passing"],
  ["🔧", "Maintenance", "Scheduled"],
  ["❌", "Build", "Failed"]
]

table =
  Table.new()
  |> Table.headers(["", "Event", "Status"])
  |> Table.rows(unicode_data)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold())
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 11. Full-Width Table with Automatic Text Wrapping
IO.puts("11. Full Terminal Width (automatic wrapping + row separators):\n")

# This table automatically:
# - Detects terminal width and wraps text within cells
# - Adds row separator lines when any row wraps (for readability)
# No configuration needed - it just works!

article_data = [
  ["AI Marketing Isn't As Scary As You Think | The Complete Roundtable Discussion",
   "Neil Patel",
   "2026-01-01",
   "marketing, search-everywhere-optimization, ai-search, cross-team-collaboration, social-search, content-strategy, Neil Patel, NP Digital, roundtable"],
  ["Predicting the 5 Top SEO Trends for 2026",
   "Neil Patel",
   "2026-01-01",
   "marketing, seo-trends, ai-search, brand-citations, voice-search, ai-advertising, Neil Patel, ChatGPT, Perplexity, tutorial"],
  ["The New SEO Playbook: Complete Guide to Modern Search Optimization",
   "Neil Patel",
   "2026-01-01",
   "marketing, ai-search, seo, content-optimization, ai-overviews, structured-data, Neil Patel, NP Digital, tutorial"]
]

table =
  Table.new()
  |> Table.headers(["Title", "Author", "Date", "Tags"])
  |> Table.rows(article_data)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:cyan))
  |> Table.render()

IO.puts(table)
IO.puts("")

# 12. Wrap Modes Comparison
IO.puts("12. Wrap Modes (:word vs :char vs :truncate):\n")

long_text = "This is a very long description that demonstrates different wrapping behaviors"

IO.puts("   :word (default) - Wraps at word boundaries:")
table =
  Table.new()
  |> Table.headers(["Mode", "Content"])
  |> Table.row(["word", long_text])
  |> Table.border(:rounded)
  |> Table.max_column_width(1, 35)
  |> Table.wrap_mode(:word)
  |> Table.render()

table |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
IO.puts("")

IO.puts("   :char - Wraps at character boundaries:")
table =
  Table.new()
  |> Table.headers(["Mode", "Content"])
  |> Table.row(["char", long_text])
  |> Table.border(:rounded)
  |> Table.max_column_width(1, 35)
  |> Table.wrap_mode(:char)
  |> Table.render()

table |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
IO.puts("")

IO.puts("   :truncate - Truncates with ellipsis:")
table =
  Table.new()
  |> Table.headers(["Mode", "Content"])
  |> Table.row(["truncate", long_text])
  |> Table.border(:rounded)
  |> Table.max_column_width(1, 35)
  |> Table.wrap_mode(:truncate)
  |> Table.render()

table |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
IO.puts("")

# 13. Dashboard-style metrics (multiple small tables)
IO.puts("13. Dashboard Layout (multiple tables):\n")

# Helper to render table with indent
render_with_indent = fn table_str, indent ->
  table_str
  |> String.split("\n")
  |> Enum.map(&(indent <> &1))
  |> Enum.join("\n")
end

system_table =
  Table.new()
  |> Table.headers(["System", "Value"])
  |> Table.row(["CPU", "23%"])
  |> Table.row(["Memory", "67%"])
  |> Table.row(["Disk", "45%"])
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:cyan))
  |> Table.render()

network_table =
  Table.new()
  |> Table.headers(["Network", "Value"])
  |> Table.row(["In", "1.2 GB/s"])
  |> Table.row(["Out", "0.8 GB/s"])
  |> Table.row(["Latency", "12ms"])
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:magenta))
  |> Table.render()

# Print side by side (simplified - just sequential for demo)
IO.puts(render_with_indent.(system_table, "   "))
IO.puts("")
IO.puts(render_with_indent.(network_table, "   "))

IO.puts("")

# 14. Test results table
IO.puts("14. Test Results:\n")

test_data = [
  ["test_user_login", "passed", "0.023s"],
  ["test_user_logout", "passed", "0.018s"],
  ["test_invalid_password", "passed", "0.045s"],
  ["test_session_timeout", "failed", "1.203s"],
  ["test_remember_me", "skipped", "0.000s"],
  ["test_oauth_flow", "passed", "0.892s"]
]

test_style = fn row, col ->
  if col == 1 do
    status = Enum.at(test_data, row) |> Enum.at(1)

    case status do
      "passed" -> style() |> foreground(:green)
      "failed" -> style() |> foreground(:red) |> bold()
      "skipped" -> style() |> foreground(:yellow) |> faint()
      _ -> style()
    end
  else
    style()
  end
end

table =
  Table.new()
  |> Table.headers(["Test Name", "Result", "Duration"])
  |> Table.rows(test_data)
  |> Table.border(:normal)
  |> Table.header_style(style() |> bold())
  |> Table.style_func(test_style)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

# Summary line
passed = Enum.count(test_data, fn [_, status, _] -> status == "passed" end)
failed = Enum.count(test_data, fn [_, status, _] -> status == "failed" end)
skipped = Enum.count(test_data, fn [_, status, _] -> status == "skipped" end)

summary =
  [
    render(style() |> foreground(:green), "#{passed} passed"),
    render(style() |> foreground(:red), "#{failed} failed"),
    render(style() |> foreground(:yellow), "#{skipped} skipped")
  ]
  |> Enum.join(", ")

IO.puts("\n   Summary: #{summary}")

IO.puts("")

# 15. Git log / Changelog style
IO.puts("15. Git Log Style:\n")

commits = [
  ["a1b2c3d", "Alice", "feat: add user authentication"],
  ["e4f5g6h", "Bob", "fix: resolve memory leak in cache"],
  ["i7j8k9l", "Carol", "docs: update API documentation"],
  ["m0n1o2p", "Alice", "refactor: extract validation logic"],
  ["q3r4s5t", "Dave", "test: add integration tests"]
]

commit_style = fn _row, col ->
  case col do
    0 -> style() |> foreground(:yellow)
    1 -> style() |> foreground(:cyan)
    2 -> style()
    _ -> style()
  end
end

table =
  Table.new()
  |> Table.headers(["Commit", "Author", "Message"])
  |> Table.rows(commits)
  |> Table.border(:rounded)
  |> Table.header_style(style() |> bold() |> foreground(:white))
  |> Table.style_func(commit_style)
  |> Table.render()

table
|> String.split("\n")
|> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
