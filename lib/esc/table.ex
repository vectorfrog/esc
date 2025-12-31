defmodule Esc.Table do
  @moduledoc """
  Styled tables for terminal output.

  Tables support headers, rows, borders, and per-cell styling.

  ## Example

      Table.new()
      |> Table.headers(["Name", "Age", "City"])
      |> Table.row(["Alice", "30", "New York"])
      |> Table.row(["Bob", "25", "Los Angeles"])
      |> Table.border(:rounded)
      |> Table.render()

  ## Styling

  Tables support multiple styling options:

  - `header_style/2` - Style for header row
  - `row_style/2` - Style for all data rows
  - `style_func/2` - Function for per-cell styling based on row/column
  """

  alias Esc.Border

  defstruct headers: [],
            rows: [],
            border: nil,
            header_style: nil,
            row_style: nil,
            style_func: nil,
            column_widths: %{}

  @type t :: %__MODULE__{
          headers: [String.t()],
          rows: [[String.t()]],
          border: atom() | nil,
          header_style: Esc.Style.t() | nil,
          row_style: Esc.Style.t() | nil,
          style_func: (non_neg_integer(), non_neg_integer() -> Esc.Style.t()) | nil,
          column_widths: %{non_neg_integer() => non_neg_integer()}
        }

  @doc """
  Creates a new empty table.
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Sets the table headers.
  """
  @spec headers(t(), [String.t()]) :: t()
  def headers(%__MODULE__{} = table, headers) when is_list(headers) do
    %{table | headers: headers}
  end

  @doc """
  Adds a single row to the table.
  """
  @spec row(t(), [String.t()]) :: t()
  def row(%__MODULE__{} = table, row) when is_list(row) do
    %{table | rows: table.rows ++ [row]}
  end

  @doc """
  Sets all rows at once.
  """
  @spec rows(t(), [[String.t()]]) :: t()
  def rows(%__MODULE__{} = table, rows) when is_list(rows) do
    %{table | rows: rows}
  end

  @doc """
  Sets the border style.

  Available styles: `:normal`, `:rounded`, `:thick`, `:double`, `:ascii`, `:markdown`
  """
  @spec border(t(), atom()) :: t()
  def border(%__MODULE__{} = table, style) when is_atom(style) do
    %{table | border: style}
  end

  @doc """
  Sets the style for header cells.
  """
  @spec header_style(t(), Esc.Style.t()) :: t()
  def header_style(%__MODULE__{} = table, style) do
    %{table | header_style: style}
  end

  @doc """
  Sets the style for all data rows.
  """
  @spec row_style(t(), Esc.Style.t()) :: t()
  def row_style(%__MODULE__{} = table, style) do
    %{table | row_style: style}
  end

  @doc """
  Sets a function for per-cell styling.

  The function receives (row_index, column_index) and returns a style.
  Row index 0 is the first data row (headers are not included).
  """
  @spec style_func(t(), (non_neg_integer(), non_neg_integer() -> Esc.Style.t())) :: t()
  def style_func(%__MODULE__{} = table, func) when is_function(func, 2) do
    %{table | style_func: func}
  end

  @doc """
  Sets the minimum width for a column.
  """
  @spec width(t(), non_neg_integer(), non_neg_integer()) :: t()
  def width(%__MODULE__{} = table, column, min_width)
      when is_integer(column) and is_integer(min_width) and column >= 0 and min_width >= 0 do
    %{table | column_widths: Map.put(table.column_widths, column, min_width)}
  end

  @doc """
  Renders the table to a string.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{headers: [], rows: []}), do: ""

  def render(%__MODULE__{} = table) do
    # Calculate column widths
    all_rows = if table.headers == [], do: table.rows, else: [table.headers | table.rows]
    col_count = all_rows |> Enum.map(&length/1) |> Enum.max(fn -> 0 end)

    col_widths =
      0..(col_count - 1)
      |> Enum.map(fn col ->
        content_width =
          all_rows
          |> Enum.map(fn row -> Enum.at(row, col, "") |> display_width() end)
          |> Enum.max(fn -> 0 end)

        min_width = Map.get(table.column_widths, col, 0)
        max(content_width, min_width)
      end)

    # Render based on border style
    if table.border do
      render_with_border(table, col_widths)
    else
      render_without_border(table, col_widths)
    end
  end

  defp render_with_border(table, col_widths) do
    border = Border.get(table.border) || Border.get(:normal)

    # Build top line with proper intersections
    top_segments = col_widths |> Enum.map(&String.duplicate(border.top, &1 + 2))
    top_line = border.top_left <> Enum.join(top_segments, border.top_mid) <> border.top_right

    # Build bottom line with proper intersections
    bottom_segments = col_widths |> Enum.map(&String.duplicate(border.bottom, &1 + 2))
    bottom_line = border.bottom_left <> Enum.join(bottom_segments, border.bottom_mid) <> border.bottom_right

    # Header separator (between header and data) with proper intersections
    header_segments = col_widths |> Enum.map(&String.duplicate(border.top, &1 + 2))
    header_sep = border.left_mid <> Enum.join(header_segments, border.cross) <> border.right_mid

    # Render headers (border lines stay unstyled to avoid background bleeding)
    lines =
      if table.headers != [] do
        header_line = render_row(table.headers, col_widths, border, fn _col -> table.header_style end)
        [top_line, header_line, header_sep]
      else
        [top_line]
      end

    # Render data rows
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.map(fn {row, row_idx} ->
        style_resolver = get_style_resolver(table, row_idx)
        render_row(row, col_widths, border, style_resolver)
      end)

    lines = lines ++ data_lines ++ [bottom_line]
    Enum.join(lines, "\n")
  end

  defp render_without_border(table, col_widths) do
    lines = []

    # Render headers
    lines =
      if table.headers != [] do
        header_line = render_row_plain(table.headers, col_widths, fn _col -> table.header_style end)
        lines ++ [header_line]
      else
        lines
      end

    # Render data rows
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.map(fn {row, row_idx} ->
        style_resolver = get_style_resolver(table, row_idx)
        render_row_plain(row, col_widths, style_resolver)
      end)

    lines = lines ++ data_lines

    Enum.join(lines, "\n")
  end

  defp render_row(row, col_widths, border, style_resolver) do
    cells =
      Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
      |> Enum.with_index()
      |> Enum.map(fn {{cell, width}, col} ->
        style = style_resolver.(col)
        padded = " " <> pad_trailing_display(cell, width) <> " "
        if style, do: Esc.render(style, padded), else: padded
      end)

    # Join cells with unstyled separators to match table borders
    border.left <> Enum.join(cells, border.left) <> border.right
  end

  defp render_row_plain(row, col_widths, style_resolver) do
    Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
    |> Enum.with_index()
    |> Enum.map(fn {{cell, width}, col} ->
      style = style_resolver.(col)
      padded = pad_trailing_display(cell, width)
      if style, do: Esc.render(style, padded), else: padded
    end)
    |> Enum.join("  ")
  end

  # Returns a function that resolves style for a given column index
  defp get_style_resolver(table, row_idx) do
    cond do
      table.style_func -> fn col -> table.style_func.(row_idx, col) end
      table.row_style -> fn _col -> table.row_style end
      true -> fn _col -> nil end
    end
  end

  # Calculate display width accounting for wide characters (emojis, CJK, etc.)
  defp display_width(string) do
    string
    |> String.graphemes()
    |> Enum.reduce(0, fn grapheme, acc ->
      acc + grapheme_width(grapheme)
    end)
  end

  # Determine width of a single grapheme
  # Wide characters (emojis, CJK) display as 2 columns in most terminals
  defp grapheme_width(grapheme) do
    codepoints = String.to_charlist(grapheme)
    first_cp = List.first(codepoints)

    # Check if this grapheme has emoji variation selector (FE0F) making it emoji presentation
    has_emoji_variation = Enum.any?(codepoints, &(&1 == 0xFE0F))

    cond do
      # If only a zero-width character
      first_cp in 0x200B..0x200D -> 0
      first_cp in 0xFE00..0xFE0F -> 0
      first_cp in 0x0300..0x036F -> 0
      # Miscellaneous symbols (0x2600-0x26FF) - remain 1 wide even with FE0F
      # These have ambiguous width and many terminals render them as 1 column
      first_cp in 0x2600..0x26FF -> 1
      # Emoji variation selector forces emoji presentation (2 wide) for other ranges
      has_emoji_variation -> 2
      # Standard emoji ranges (always 2 wide)
      first_cp in 0x1F300..0x1F9FF -> 2
      first_cp in 0x1F600..0x1F64F -> 2
      first_cp in 0x1F680..0x1F6FF -> 2
      first_cp in 0x1F1E0..0x1F1FF -> 2
      first_cp in 0x1F400..0x1F4FF -> 2
      first_cp in 0x1F500..0x1F5FF -> 2
      # Dingbats with default emoji presentation (2 wide)
      first_cp in 0x2702..0x27B0 -> 2
      # CJK ranges
      first_cp in 0x4E00..0x9FFF -> 2
      first_cp in 0x3400..0x4DBF -> 2
      first_cp in 0xF900..0xFAFF -> 2
      first_cp in 0x3000..0x303F -> 2
      first_cp in 0xFF00..0xFFEF -> 2
      # Box drawing and block elements - always 1 wide
      first_cp in 0x2500..0x257F -> 1
      first_cp in 0x2580..0x259F -> 1
      # Default: 1 column
      true -> 1
    end
  end

  # Pad string to target display width
  defp pad_trailing_display(string, target_width) do
    current_width = display_width(string)
    padding_needed = max(target_width - current_width, 0)
    string <> String.duplicate(" ", padding_needed)
  end
end
