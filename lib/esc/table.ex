defmodule Esc.Table do
  @moduledoc """
  Styled tables for terminal output.

  Tables support headers, rows, borders, per-cell styling, and automatic text wrapping.

  ## Example

      Table.new()
      |> Table.headers(["Name", "Age", "City"])
      |> Table.row(["Alice", "30", "New York"])
      |> Table.row(["Bob", "25", "Los Angeles"])
      |> Table.border(:rounded)
      |> Table.render()

  ## Automatic Terminal Width

  Tables automatically detect terminal width and wrap text within cells to fit.
  Long content wraps at word boundaries while preserving table structure.
  When any row wraps, horizontal separator lines are added between rows for readability.

  To set a specific width instead of auto-detecting:

      Table.new()
      |> Table.max_width(100)      # Fixed 100 columns
      |> Table.render()

  Control row separators with `row_separator/2`:
  - `:auto` (default) - Add separators only when rows wrap
  - `:always` - Always add separators
  - `:never` - Never add separators

  ## Column Width Control

  Control individual column widths:

      Table.new()
      |> Table.width(0, 20)            # Minimum 20 chars for column 0
      |> Table.max_column_width(2, 30) # Maximum 30 chars for column 2
      |> Table.render()

  ## Wrap Modes

  Control how text wraps with `wrap_mode/2`:

  - `:word` (default) - Wrap at word boundaries
  - `:char` - Wrap at character boundaries (for CJK text or long words)
  - `:truncate` - Truncate with ellipsis instead of wrapping

  ## Styling

  Tables support multiple styling options:

  - `header_style/2` - Style for header row
  - `row_style/2` - Style for all data rows
  - `style_func/2` - Function for per-cell styling based on row/column

  ## Theme Integration

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default),
  the table automatically uses theme colors:

  - Header text: theme `:header` color (bold)
  - Border: theme `:muted` color

  Explicit styles override theme colors. Use `use_theme(table, false)` to disable.
  """

  alias Esc.Border

  defstruct headers: [],
            rows: [],
            border: nil,
            header_style: nil,
            row_style: nil,
            style_func: nil,
            column_widths: %{},
            max_column_widths: %{},
            max_width: nil,
            wrap_mode: :word,
            row_separator: :auto,
            use_theme: true

  @type wrap_mode :: :word | :char | :truncate
  @type row_separator :: :auto | :always | :never
  @type t :: %__MODULE__{
          headers: [String.t()],
          rows: [[String.t()]],
          border: atom() | nil,
          header_style: Esc.Style.t() | nil,
          row_style: Esc.Style.t() | nil,
          style_func: (non_neg_integer(), non_neg_integer() -> Esc.Style.t()) | nil,
          column_widths: %{non_neg_integer() => non_neg_integer()},
          max_column_widths: %{non_neg_integer() => non_neg_integer()},
          max_width: non_neg_integer() | :terminal | nil,
          wrap_mode: wrap_mode(),
          row_separator: row_separator(),
          use_theme: boolean()
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
  Sets the maximum width for a column.

  Text exceeding this width will be wrapped according to the `wrap_mode` setting.

  ## Examples

      Table.new()
      |> Table.max_column_width(1, 30)  # Limit column 1 to 30 characters
  """
  @spec max_column_width(t(), non_neg_integer(), non_neg_integer()) :: t()
  def max_column_width(%__MODULE__{} = table, column, max_width)
      when is_integer(column) and is_integer(max_width) and column >= 0 and max_width > 0 do
    %{table | max_column_widths: Map.put(table.max_column_widths, column, max_width)}
  end

  @doc """
  Sets the maximum width for the entire table.

  When set, columns will be sized proportionally to fit within this width,
  and text will wrap within cells as needed.

  Pass `:terminal` to use the current terminal width (with fallback to 80 columns).

  ## Examples

      Table.new()
      |> Table.max_width(80)       # Fixed 80-column width

      Table.new()
      |> Table.max_width(:terminal)  # Use terminal width
  """
  @spec max_width(t(), non_neg_integer() | :terminal) :: t()
  def max_width(%__MODULE__{} = table, :terminal) do
    %{table | max_width: :terminal}
  end

  def max_width(%__MODULE__{} = table, width)
      when is_integer(width) and width > 0 do
    %{table | max_width: width}
  end

  @doc """
  Sets the text wrapping mode for cells.

  Available modes:
  - `:word` (default) - Wrap at word boundaries when possible
  - `:char` - Wrap at character boundaries (for CJK text or long words)
  - `:truncate` - Truncate with ellipsis instead of wrapping

  ## Examples

      Table.new()
      |> Table.max_width(60)
      |> Table.wrap_mode(:word)
  """
  @spec wrap_mode(t(), wrap_mode()) :: t()
  def wrap_mode(%__MODULE__{} = table, mode)
      when mode in [:word, :char, :truncate] do
    %{table | wrap_mode: mode}
  end

  @doc """
  Controls horizontal separator lines between data rows.

  Available modes:
  - `:auto` (default) - Add separators only when any row has wrapped text
  - `:always` - Always add separators between rows
  - `:never` - Never add separators between rows

  ## Examples

      Table.new()
      |> Table.row_separator(:always)  # Always show row lines
  """
  @spec row_separator(t(), row_separator()) :: t()
  def row_separator(%__MODULE__{} = table, mode)
      when mode in [:auto, :always, :never] do
    %{table | row_separator: mode}
  end

  @doc """
  Enables or disables automatic theme colors.

  When enabled (default), the table uses theme colors for:
  - Header text (`:header` color, bold)
  - Borders (`:muted` color)

  Explicit styles (via `header_style/2`, `row_style/2`) override theme colors.

  ## Examples

      # Disable theme colors
      Table.new() |> Table.use_theme(false)

      # Re-enable theme colors
      Table.new() |> Table.use_theme(true)
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = table, enabled) when is_boolean(enabled) do
    %{table | use_theme: enabled}
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

    # Auto-detect terminal width if no explicit max_width set
    max_width_setting = table.max_width || :terminal
    effective_max_width = resolve_max_width(max_width_setting, table.border, col_count)

    # Calculate column widths with constraints
    col_widths = calculate_column_widths(table, all_rows, col_count, effective_max_width)

    # Render based on border style
    if table.border do
      render_with_border(table, col_widths)
    else
      render_without_border(table, col_widths)
    end
  end

  # Resolve max_width setting to actual pixels
  defp resolve_max_width(nil, _border, _col_count), do: nil
  defp resolve_max_width(:terminal, border, col_count) do
    terminal_width = get_terminal_width()
    # Subtract border overhead: 1 left + 1 right + (col_count - 1) separators + 2 padding per cell
    border_overhead = if border, do: 2 + (col_count - 1) + (col_count * 2), else: (col_count - 1) * 2
    max(terminal_width - border_overhead, col_count * 3)  # Minimum 3 chars per column
  end
  defp resolve_max_width(width, _border, _col_count), do: width

  # Calculate column widths respecting min/max constraints
  defp calculate_column_widths(table, all_rows, col_count, effective_max_width) do
    # First pass: calculate natural widths
    natural_widths =
      0..(col_count - 1)
      |> Enum.map(fn col ->
        content_width =
          all_rows
          |> Enum.map(fn row -> Enum.at(row, col, "") |> display_width() end)
          |> Enum.max(fn -> 0 end)

        min_width = Map.get(table.column_widths, col, 0)
        max(content_width, min_width)
      end)

    # Apply per-column max widths
    constrained_widths =
      natural_widths
      |> Enum.with_index()
      |> Enum.map(fn {width, col} ->
        case Map.get(table.max_column_widths, col) do
          nil -> width
          max_col_width -> min(width, max_col_width)
        end
      end)

    # Apply table max_width if set
    if effective_max_width do
      distribute_widths(constrained_widths, effective_max_width, table.border)
    else
      constrained_widths
    end
  end

  # Distribute available width across columns intelligently
  # Shrinks widest columns first while preserving narrow columns
  defp distribute_widths(widths, max_width, border) do
    total_content = Enum.sum(widths)
    col_count = length(widths)

    # Calculate border/separator overhead
    overhead = if border, do: 2 + (col_count - 1) + (col_count * 2), else: (col_count - 1) * 2
    available = max(max_width - overhead, col_count * 3)

    if total_content <= available do
      # Everything fits
      widths
    else
      # Need to shrink - prioritize shrinking widest columns
      shrink_widest_first(widths, available)
    end
  end

  # Shrink columns starting from the widest, preserving narrow ones
  defp shrink_widest_first(widths, available) do
    total = Enum.sum(widths)
    excess = total - available

    if excess <= 0 do
      widths
    else
      # Find columns that can be shrunk (wider than minimum)
      min_width = 8  # Minimum reasonable column width
      indexed = Enum.with_index(widths)

      # Sort by width descending to shrink widest first
      sorted = Enum.sort_by(indexed, fn {w, _} -> -w end)

      # Distribute excess reduction among widest columns
      {new_widths, _} =
        Enum.reduce(sorted, {widths, excess}, fn {width, idx}, {acc_widths, remaining_excess} ->
          if remaining_excess <= 0 or width <= min_width do
            {acc_widths, remaining_excess}
          else
            # Calculate how much this column can give up
            shrinkable = width - min_width
            # Take a fair share of remaining excess
            shrink_amount = min(shrinkable, ceil(remaining_excess / max(1, count_shrinkable(acc_widths, min_width))))
            new_width = max(width - shrink_amount, min_width)
            actual_shrink = width - new_width

            {List.replace_at(acc_widths, idx, new_width), remaining_excess - actual_shrink}
          end
        end)

      # If still over, do a second pass with proportional reduction on remaining excess
      if Enum.sum(new_widths) > available do
        still_excess = Enum.sum(new_widths) - available
        Enum.map(new_widths, fn w ->
          reduction = if w > min_width, do: ceil(still_excess * w / Enum.sum(new_widths)), else: 0
          max(w - reduction, 3)
        end)
      else
        new_widths
      end
    end
  end

  defp count_shrinkable(widths, min_width) do
    Enum.count(widths, fn w -> w > min_width end)
  end

  defp render_with_border(table, col_widths) do
    border = Border.get(table.border) || Border.get(:normal)
    border_color = get_effective_border_color(table)

    # Build top line with proper intersections
    top_segments = col_widths |> Enum.map(&String.duplicate(border.top, &1 + 2))
    top_line = border.top_left <> Enum.join(top_segments, border.top_mid) <> border.top_right
    top_line = apply_border_color(top_line, border_color)

    # Build bottom line with proper intersections
    bottom_segments = col_widths |> Enum.map(&String.duplicate(border.bottom, &1 + 2))
    bottom_line = border.bottom_left <> Enum.join(bottom_segments, border.bottom_mid) <> border.bottom_right
    bottom_line = apply_border_color(bottom_line, border_color)

    # Header separator (between header and data) with proper intersections
    header_segments = col_widths |> Enum.map(&String.duplicate(border.top, &1 + 2))
    header_sep = border.left_mid <> Enum.join(header_segments, border.cross) <> border.right_mid
    header_sep = apply_border_color(header_sep, border_color)

    # Render headers (border lines stay unstyled to avoid background bleeding)
    lines =
      if table.headers != [] do
        header_style = get_effective_header_style(table)
        header_lines = render_wrapped_row(table.headers, col_widths, table.wrap_mode, border, border_color, fn _col -> header_style end)
        [top_line] ++ header_lines ++ [header_sep]
      else
        [top_line]
      end

    # Row separator line (same as header separator)
    row_sep = header_sep

    # Render data rows with separators based on row_separator setting
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.map(fn {row, row_idx} ->
        style_resolver = get_style_resolver(table, row_idx)
        {render_wrapped_row(row, col_widths, table.wrap_mode, border, border_color, style_resolver), row_idx}
      end)
      |> insert_row_separators(table.row_separator, row_sep)

    lines = lines ++ data_lines ++ [bottom_line]
    Enum.join(lines, "\n")
  end

  # Insert separators between rows based on mode
  defp insert_row_separators(rows_with_idx, mode, separator) do
    case mode do
      :never ->
        rows_with_idx |> Enum.flat_map(fn {lines, _idx} -> lines end)

      :always ->
        rows_with_idx
        |> Enum.with_index()
        |> Enum.flat_map(fn {{lines, _row_idx}, enum_idx} ->
          if enum_idx > 0, do: [separator | lines], else: lines
        end)

      :auto ->
        # Add separators if any row has multiple lines (wrapped)
        has_wrapped = Enum.any?(rows_with_idx, fn {lines, _idx} -> length(lines) > 1 end)

        if has_wrapped do
          rows_with_idx
          |> Enum.with_index()
          |> Enum.flat_map(fn {{lines, _row_idx}, enum_idx} ->
            if enum_idx > 0, do: [separator | lines], else: lines
          end)
        else
          rows_with_idx |> Enum.flat_map(fn {lines, _idx} -> lines end)
        end
    end
  end

  defp render_without_border(table, col_widths) do
    lines = []

    # Render headers
    lines =
      if table.headers != [] do
        header_style = get_effective_header_style(table)
        header_lines = render_wrapped_row_plain(table.headers, col_widths, table.wrap_mode, fn _col -> header_style end)
        lines ++ header_lines
      else
        lines
      end

    # Render data rows
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, row_idx} ->
        style_resolver = get_style_resolver(table, row_idx)
        render_wrapped_row_plain(row, col_widths, table.wrap_mode, style_resolver)
      end)

    lines = lines ++ data_lines

    Enum.join(lines, "\n")
  end

  # Render a row with text wrapping - returns list of lines
  defp render_wrapped_row(row, col_widths, wrap_mode, border, border_color, style_resolver) do
    # Wrap each cell and get list of lines per cell
    wrapped_cells =
      Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
      |> Enum.map(fn {cell, width} ->
        wrap_text(cell, width, wrap_mode)
      end)

    # Find max height (most lines in any cell)
    max_lines = wrapped_cells |> Enum.map(&length/1) |> Enum.max(fn -> 1 end)

    # Pad cells with fewer lines
    padded_cells =
      Enum.zip(wrapped_cells, col_widths)
      |> Enum.map(fn {lines, width} ->
        padding_needed = max_lines - length(lines)
        (lines ++ List.duplicate("", padding_needed))
        |> Enum.map(&pad_trailing_display(&1, width))
      end)

    # Render each line of the row
    0..(max_lines - 1)
    |> Enum.map(fn line_idx ->
      cells =
        padded_cells
        |> Enum.with_index()
        |> Enum.map(fn {cell_lines, col} ->
          cell_content = Enum.at(cell_lines, line_idx, "")
          style = style_resolver.(col)
          padded = " " <> cell_content <> " "
          if style, do: Esc.render(style, padded), else: padded
        end)

      left = apply_border_color(border.left, border_color)
      right = apply_border_color(border.right, border_color)
      sep = apply_border_color(border.left, border_color)
      left <> Enum.join(cells, sep) <> right
    end)
  end

  # Render a row without borders with text wrapping - returns list of lines
  defp render_wrapped_row_plain(row, col_widths, wrap_mode, style_resolver) do
    # Wrap each cell and get list of lines per cell
    wrapped_cells =
      Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
      |> Enum.map(fn {cell, width} ->
        wrap_text(cell, width, wrap_mode)
      end)

    # Find max height (most lines in any cell)
    max_lines = wrapped_cells |> Enum.map(&length/1) |> Enum.max(fn -> 1 end)

    # Pad cells with fewer lines
    padded_cells =
      Enum.zip(wrapped_cells, col_widths)
      |> Enum.map(fn {lines, width} ->
        padding_needed = max_lines - length(lines)
        lines ++ List.duplicate("", padding_needed)
        |> Enum.map(&pad_trailing_display(&1, width))
      end)

    # Render each line of the row
    0..(max_lines - 1)
    |> Enum.map(fn line_idx ->
      padded_cells
      |> Enum.with_index()
      |> Enum.map(fn {cell_lines, col} ->
        cell_content = Enum.at(cell_lines, line_idx, "")
        style = style_resolver.(col)
        if style, do: Esc.render(style, cell_content), else: cell_content
      end)
      |> Enum.join("  ")
    end)
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

  # Theme-aware style resolution

  # Gets effective header style: explicit style > theme style > nil
  defp get_effective_header_style(table) do
    case {table.header_style, table.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        # Explicit style takes precedence
        style

      {nil, true, theme} when not is_nil(theme) ->
        # Use theme colors
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :header))
        |> Esc.bold()

      _ ->
        nil
    end
  end

  # Gets effective border color from theme
  defp get_effective_border_color(table) do
    case {table.use_theme, Esc.get_theme()} do
      {true, theme} when not is_nil(theme) ->
        Esc.Theme.color(theme, :muted)

      _ ->
        nil
    end
  end

  # Applies border color to a string (for border characters)
  defp apply_border_color(string, nil), do: string

  defp apply_border_color(string, color) do
    Esc.style()
    |> Esc.foreground(color)
    |> Esc.render(string)
  end

  # Text wrapping functions

  @doc false
  def get_terminal_width do
    case :io.columns() do
      {:ok, cols} -> cols
      {:error, _} -> 80
    end
  end

  # Wraps text to fit within max_width according to the specified mode
  defp wrap_text(text, max_width, mode) when max_width > 0 do
    case mode do
      :truncate -> truncate_text(text, max_width)
      :char -> wrap_by_char(text, max_width)
      :word -> wrap_by_word(text, max_width)
    end
  end

  defp wrap_text(text, _max_width, _mode), do: [text]

  # Truncate text with ellipsis
  defp truncate_text(text, max_width) do
    if display_width(text) <= max_width do
      [text]
    else
      # Reserve 1 char for ellipsis
      truncated = truncate_to_display_width(text, max_width - 1)
      [truncated <> "…"]
    end
  end

  # Truncate string to fit display width (accounting for wide chars)
  defp truncate_to_display_width(string, max_width) do
    string
    |> String.graphemes()
    |> Enum.reduce_while({"", 0}, fn grapheme, {acc, width} ->
      gw = grapheme_width(grapheme)

      if width + gw <= max_width do
        {:cont, {acc <> grapheme, width + gw}}
      else
        {:halt, {acc, width}}
      end
    end)
    |> elem(0)
  end

  # Wrap by character boundaries (good for CJK text or words longer than max_width)
  defp wrap_by_char(text, max_width) do
    text
    |> String.graphemes()
    |> Enum.reduce({[], "", 0}, fn grapheme, {lines, current_line, current_width} ->
      gw = grapheme_width(grapheme)

      if current_width + gw > max_width and current_line != "" do
        # Start a new line
        {[current_line | lines], grapheme, gw}
      else
        {lines, current_line <> grapheme, current_width + gw}
      end
    end)
    |> then(fn {lines, current_line, _} ->
      if current_line == "" do
        Enum.reverse(lines)
      else
        Enum.reverse([current_line | lines])
      end
    end)
    |> case do
      [] -> [""]
      lines -> lines
    end
  end

  # Wrap by word boundaries (falls back to char wrap for long words)
  defp wrap_by_word(text, max_width) do
    # Split into tokens (words and whitespace)
    tokens = Regex.scan(~r/\S+|\s+/, text) |> List.flatten()

    tokens
    |> Enum.reduce({[], "", 0}, fn token, {lines, current_line, current_width} ->
      token_width = display_width(token)

      cond do
        # Whitespace at start of line - skip
        current_line == "" and String.trim(token) == "" ->
          {lines, current_line, current_width}

        # Token fits on current line
        current_width + token_width <= max_width ->
          {lines, current_line <> token, current_width + token_width}

        # Word is longer than max_width - need to char wrap it
        token_width > max_width and String.trim(token) != "" ->
          # First, finish current line if it has content
          new_lines = if current_line != "", do: [current_line | lines], else: lines
          # Then char-wrap the long word
          wrapped = wrap_by_char(String.trim(token), max_width)

          case wrapped do
            [] ->
              {new_lines, "", 0}

            [single] ->
              {new_lines, single, display_width(single)}

            multiple ->
              # All but last go to lines, last becomes current
              {last, rest} = {List.last(multiple), Enum.drop(multiple, -1)}
              {Enum.reverse(rest) ++ new_lines, last, display_width(last)}
          end

        # Token doesn't fit - start new line
        true ->
          trimmed = String.trim_trailing(current_line)
          new_lines = if trimmed != "", do: [trimmed | lines], else: lines
          token_trimmed = String.trim_leading(token)
          {new_lines, token_trimmed, display_width(token_trimmed)}
      end
    end)
    |> then(fn {lines, current_line, _} ->
      trimmed = String.trim_trailing(current_line)

      if trimmed == "" do
        Enum.reverse(lines)
      else
        Enum.reverse([trimmed | lines])
      end
    end)
    |> case do
      [] -> [""]
      lines -> lines
    end
  end
end
