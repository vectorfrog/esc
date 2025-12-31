# Style & Box Demo
# Run with: mix run examples/style_demo.exs

import Esc

IO.puts("\n=== Esc Style & Box Demo ===\n")

# 1. Text formatting
IO.puts("1. Text Formatting:\n")

formats = [
  {"Bold", style() |> bold()},
  {"Italic", style() |> italic()},
  {"Underline", style() |> underline()},
  {"Strikethrough", style() |> strikethrough()},
  {"Faint/Dim", style() |> faint()},
  {"Reverse", style() |> reverse()}
]

for {label, s} <- formats do
  IO.puts("   #{render(s, label)}")
end

IO.puts("")

# 2. Combined formatting
IO.puts("2. Combined Formatting:\n")

IO.puts("   #{render(style() |> bold() |> italic(), "Bold + Italic")}")
IO.puts("   #{render(style() |> bold() |> underline(), "Bold + Underline")}")
IO.puts("   #{render(style() |> bold() |> foreground(:cyan), "Bold + Cyan")}")
IO.puts("   #{render(style() |> italic() |> foreground(:yellow) |> background(:blue), "Italic + Yellow on Blue")}")

IO.puts("")

# 3. Padding
IO.puts("3. Padding:\n")

IO.puts("   No padding:")
IO.puts("   " <> render(style() |> border(:rounded), "Hello"))

IO.puts("\n   Padding all sides (1):")
text = render(style() |> padding(1) |> border(:rounded), "Hello")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Padding vertical/horizontal (1, 3):")
text = render(style() |> padding(1, 3) |> border(:rounded), "Hello")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 4. Margins
IO.puts("4. Margins:\n")

IO.puts("   Box with margin (1, 2):")
text = render(style() |> margin(1, 2) |> border(:rounded), "Content")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 5. Border styles
IO.puts("5. Border Styles:\n")

border_styles = [:normal, :rounded, :thick, :double, :ascii]

for b <- border_styles do
  IO.puts("   #{b}:")
  text = render(style() |> border(b) |> padding(0, 1), "Box")
  text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
  IO.puts("")
end

# 6. Colored borders
IO.puts("6. Colored Borders:\n")

IO.puts("   Cyan border:")
text = render(style() |> border(:rounded) |> border_foreground(:cyan) |> padding(0, 1), "Styled")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Yellow on blue border:")
text = render(style() |> border(:double) |> border_foreground(:yellow) |> border_background(:blue) |> padding(0, 1), "Fancy")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 7. Partial borders
IO.puts("7. Partial Borders:\n")

IO.puts("   Top and bottom only:")
text = render(
  style()
  |> border(:normal)
  |> border_left(false)
  |> border_right(false)
  |> padding(0, 1),
  "Header"
)
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Left border only:")
text = render(
  style()
  |> border(:thick)
  |> border_top(false)
  |> border_right(false)
  |> border_bottom(false)
  |> border_foreground(:green),
  "Quote style"
)
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 8. Fixed dimensions
IO.puts("8. Fixed Dimensions:\n")

IO.puts("   Width 20, left aligned:")
text = render(style() |> width(20) |> border(:rounded), "Short")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Width 20, center aligned:")
text = render(style() |> width(20) |> align(:center) |> border(:rounded), "Center")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Width 20, right aligned:")
text = render(style() |> width(20) |> align(:right) |> border(:rounded), "Right")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 9. Height and vertical alignment
IO.puts("9. Vertical Alignment:\n")

IO.puts("   Height 5, top:")
text = render(style() |> width(15) |> height(5) |> vertical_align(:top) |> border(:rounded), "Top")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Height 5, middle:")
text = render(style() |> width(15) |> height(5) |> vertical_align(:middle) |> border(:rounded), "Middle")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Height 5, bottom:")
text = render(style() |> width(15) |> height(5) |> vertical_align(:bottom) |> border(:rounded), "Bottom")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 10. Horizontal joining
IO.puts("10. Horizontal Joining:\n")

box1 = render(style() |> border(:rounded) |> padding(0, 1), "Box 1")
box2 = render(style() |> border(:rounded) |> padding(0, 1), "Box 2")
box3 = render(style() |> border(:rounded) |> padding(0, 1), "Box 3")

joined = join_horizontal([box1, box2, box3])
joined |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 11. Vertical joining
IO.puts("11. Vertical Joining:\n")

box1 = render(style() |> border(:rounded) |> padding(0, 1), "Top Box")
box2 = render(style() |> border(:rounded) |> padding(0, 1), "Bottom Box")

joined = join_vertical([box1, box2], :center)
joined |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 12. Dashboard layout
IO.puts("12. Dashboard Layout:\n")

header = render(
  style()
  |> width(50)
  |> align(:center)
  |> bold()
  |> foreground(:cyan)
  |> border(:double)
  |> padding(0, 1),
  "System Dashboard"
)

stat1 = render(
  style()
  |> width(15)
  |> align(:center)
  |> border(:rounded)
  |> border_foreground(:green),
  "CPU\n23%"
)

stat2 = render(
  style()
  |> width(15)
  |> align(:center)
  |> border(:rounded)
  |> border_foreground(:yellow),
  "Memory\n67%"
)

stat3 = render(
  style()
  |> width(16)
  |> align(:center)
  |> border(:rounded)
  |> border_foreground(:red),
  "Disk\n89%"
)

stats_row = join_horizontal([stat1, stat2, stat3])
dashboard = join_vertical([header, stats_row], :center)

dashboard |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 13. Card component
IO.puts("13. Card Component:\n")

card = render(
  style()
  |> width(40)
  |> border(:rounded)
  |> padding(1, 2)
  |> border_foreground(:blue),
  "User Profile\n\nName: Alice Smith\nEmail: alice@example.com\nRole: Administrator"
)

card |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 14. Alert boxes
IO.puts("14. Alert Boxes:\n")

success = render(
  style()
  |> border(:rounded)
  |> border_foreground(:green)
  |> foreground(:green)
  |> padding(0, 1),
  "✓ Operation completed successfully"
)

warning = render(
  style()
  |> border(:rounded)
  |> border_foreground(:yellow)
  |> foreground(:yellow)
  |> padding(0, 1),
  "⚠ Warning: Disk space low"
)

error = render(
  style()
  |> border(:rounded)
  |> border_foreground(:red)
  |> foreground(:red)
  |> bold()
  |> padding(0, 1),
  "✗ Error: Connection failed"
)

success |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
IO.puts("")
warning |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))
IO.puts("")
error |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

# 15. Placement
IO.puts("15. Placement (centered in 30x5 box):\n")

placed = place(30, 5, :center, :middle, "Centered!")
placed |> String.split("\n") |> Enum.each(&IO.puts("   |#{&1}|"))

IO.puts("")

# 16. Inline mode
IO.puts("16. Inline Mode:\n")

normal = render(style() |> foreground(:cyan), "Multi\nLine\nText")
IO.puts("   Normal:")
normal |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

inline = render(style() |> foreground(:cyan) |> inline(true), "Multi\nLine\nText")
IO.puts("\n   Inline: #{inline}")

IO.puts("")

# 17. Max dimensions (truncation)
IO.puts("17. Max Dimensions (truncation):\n")

long_text = "This is a very long string that will be truncated"
truncated = render(style() |> max_width(25), long_text)
IO.puts("   Original:  #{long_text}")
IO.puts("   Truncated: #{truncated}")

IO.puts("")

# 18. Style inheritance
IO.puts("18. Style Inheritance:\n")

base_style = style() |> bold() |> foreground(:cyan) |> border(:rounded)

derived1 = style() |> foreground(:yellow) |> inherit(base_style)
derived2 = style() |> inherit(base_style)

IO.puts("   Base style (bold cyan):")
text = render(base_style |> padding(0, 1), "Base")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Derived (yellow override, inherited bold/border):")
text = render(derived1 |> padding(0, 1), "Derived 1")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("\n   Derived (all inherited):")
text = render(derived2 |> padding(0, 1), "Derived 2")
text |> String.split("\n") |> Enum.each(&IO.puts("   #{&1}"))

IO.puts("")

IO.puts("=== Demo Complete ===\n")
