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
          |> Enum.map(fn row -> Enum.at(row, col, "") |> String.length() end)
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

    # Build separator line
    separator_content = col_widths |> Enum.map(&String.duplicate(border.top, &1 + 2)) |> Enum.join(border.top)
    top_line = border.top_left <> separator_content <> border.top_right
    bottom_line = border.bottom_left <> String.replace(separator_content, border.top, border.bottom) <> border.bottom_right

    # Header separator (between header and data)
    header_sep = border.left <> (col_widths |> Enum.map(&String.duplicate(border.bottom, &1 + 2)) |> Enum.join(border.top)) <> border.right

    lines = [top_line]

    # Render headers
    lines =
      if table.headers != [] do
        header_line = render_row(table.headers, col_widths, border, table.header_style)
        lines ++ [header_line, header_sep]
      else
        lines
      end

    # Render data rows
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.map(fn {row, idx} ->
        style = get_row_style(table, idx)
        render_row(row, col_widths, border, style)
      end)

    lines = lines ++ data_lines ++ [bottom_line]
    Enum.join(lines, "\n")
  end

  defp render_without_border(table, col_widths) do
    lines = []

    # Render headers
    lines =
      if table.headers != [] do
        header_line = render_row_plain(table.headers, col_widths, table.header_style)
        lines ++ [header_line]
      else
        lines
      end

    # Render data rows
    data_lines =
      table.rows
      |> Enum.with_index()
      |> Enum.map(fn {row, idx} ->
        style = get_row_style(table, idx)
        render_row_plain(row, col_widths, style)
      end)

    lines = lines ++ data_lines

    Enum.join(lines, "\n")
  end

  defp render_row(row, col_widths, border, style) do
    cells =
      Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
      |> Enum.with_index()
      |> Enum.map(fn {{cell, width}, _col} ->
        padded = String.pad_trailing(cell, width)
        styled = if style, do: Esc.render(style, padded), else: padded
        " " <> styled <> " "
      end)

    border.left <> Enum.join(cells, border.left) <> border.right
  end

  defp render_row_plain(row, col_widths, style) do
    Enum.zip(row ++ List.duplicate("", length(col_widths) - length(row)), col_widths)
    |> Enum.map(fn {cell, width} ->
      padded = String.pad_trailing(cell, width)
      if style, do: Esc.render(style, padded), else: padded
    end)
    |> Enum.join("  ")
  end

  defp get_row_style(table, row_idx) do
    cond do
      table.style_func -> table.style_func.(row_idx, 0)
      table.row_style -> table.row_style
      true -> nil
    end
  end
end
