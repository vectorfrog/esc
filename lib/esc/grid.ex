defmodule Esc.Grid do
  @moduledoc false
  # Internal module for shared grid rendering logic between SelectTable and MultiSelectTable

  @doc """
  Renders rows of cells as a grid with optional border.
  """
  def render(rows, cell_width, border, border_style) do
    box = get_box_chars(border)
    render_grid(rows, cell_width, box, border_style)
  end

  @doc """
  Calculates display width of a string, accounting for wide characters (emojis, CJK).
  """
  def display_width(string) do
    string
    |> String.graphemes()
    |> Enum.reduce(0, fn grapheme, acc -> acc + grapheme_width(grapheme) end)
  end

  @doc """
  Applies an Esc style to content, or returns content unchanged if style is nil.
  """
  def apply_style(content, nil), do: content
  def apply_style(content, style), do: Esc.render(style, content)

  # ===========================================================================
  # Private - Grid Rendering
  # ===========================================================================

  defp render_grid(rows, _cell_width, nil, _border_style) do
    # No border - just join cells with spaces
    rows
    |> Enum.map(fn cells -> Enum.join(cells, " ") end)
    |> Enum.join("\n")
  end

  defp render_grid(rows, cell_width, box, border_style) do
    col_count = length(List.first(rows) || [])
    inner_width = cell_width + 2  # 1 space padding each side

    # Build horizontal lines
    top_line = box.top_left <> String.duplicate(box.horizontal, inner_width)
    top_line = top_line <> String.duplicate(box.top_mid <> String.duplicate(box.horizontal, inner_width), col_count - 1)
    top_line = top_line <> box.top_right

    bottom_line = box.bottom_left <> String.duplicate(box.horizontal, inner_width)
    bottom_line = bottom_line <> String.duplicate(box.bottom_mid <> String.duplicate(box.horizontal, inner_width), col_count - 1)
    bottom_line = bottom_line <> box.bottom_right

    # Style the border lines
    styled_top = apply_style(top_line, border_style)
    styled_bottom = apply_style(bottom_line, border_style)

    # Build content rows
    content_lines =
      Enum.map(rows, fn cells ->
        left = apply_style(box.vertical, border_style)
        sep = apply_style(box.vertical, border_style)
        right = apply_style(box.vertical, border_style)

        cells_with_padding = Enum.map(cells, fn cell -> " #{cell} " end)
        left <> Enum.join(cells_with_padding, sep) <> right
      end)

    [styled_top | content_lines] ++ [styled_bottom]
    |> Enum.join("\n")
  end

  # ===========================================================================
  # Private - Box Characters
  # ===========================================================================

  defp get_box_chars(nil), do: nil
  defp get_box_chars(:rounded) do
    %{
      top_left: "╭", top_right: "╮", bottom_left: "╰", bottom_right: "╯",
      top_mid: "┬", bottom_mid: "┴",
      horizontal: "─", vertical: "│"
    }
  end
  defp get_box_chars(:normal) do
    %{
      top_left: "┌", top_right: "┐", bottom_left: "└", bottom_right: "┘",
      top_mid: "┬", bottom_mid: "┴",
      horizontal: "─", vertical: "│"
    }
  end
  defp get_box_chars(:thick) do
    %{
      top_left: "┏", top_right: "┓", bottom_left: "┗", bottom_right: "┛",
      top_mid: "┳", bottom_mid: "┻",
      horizontal: "━", vertical: "┃"
    }
  end
  defp get_box_chars(:double) do
    %{
      top_left: "╔", top_right: "╗", bottom_left: "╚", bottom_right: "╝",
      top_mid: "╦", bottom_mid: "╩",
      horizontal: "═", vertical: "║"
    }
  end
  defp get_box_chars(:ascii) do
    %{
      top_left: "+", top_right: "+", bottom_left: "+", bottom_right: "+",
      top_mid: "+", bottom_mid: "+",
      horizontal: "-", vertical: "|"
    }
  end
  defp get_box_chars(_), do: get_box_chars(:rounded)

  # ===========================================================================
  # Private - Display Width
  # ===========================================================================

  defp grapheme_width(grapheme) do
    codepoints = String.to_charlist(grapheme)
    first_cp = List.first(codepoints)
    has_emoji_variation = Enum.any?(codepoints, &(&1 == 0xFE0F))

    cond do
      first_cp in 0x200B..0x200D -> 0
      first_cp in 0xFE00..0xFE0F -> 0
      first_cp in 0x0300..0x036F -> 0
      first_cp in 0x2600..0x26FF -> 1
      # Dingbats (0x2700-0x27BF) are typically width 1 unless with emoji variation selector
      first_cp in 0x2700..0x27BF -> 1
      has_emoji_variation -> 2
      first_cp in 0x1F300..0x1F9FF -> 2
      first_cp in 0x1F600..0x1F64F -> 2
      first_cp in 0x1F680..0x1F6FF -> 2
      first_cp in 0x1F1E0..0x1F1FF -> 2
      first_cp in 0x1F400..0x1F4FF -> 2
      first_cp in 0x1F500..0x1F5FF -> 2
      first_cp in 0x4E00..0x9FFF -> 2
      first_cp in 0x3400..0x4DBF -> 2
      first_cp in 0xF900..0xFAFF -> 2
      first_cp in 0x3000..0x303F -> 2
      first_cp in 0xFF00..0xFFEF -> 2
      first_cp in 0x2500..0x257F -> 1
      first_cp in 0x2580..0x259F -> 1
      true -> 1
    end
  end
end
