defmodule Esc.SelectTable do
  @moduledoc """
  Interactive table-based single selection for terminal applications.

  SelectTable displays items in a grid layout and allows users to navigate
  with arrow keys (or h/j/k/l) and select with Enter.

  ## Example

      alias Esc.SelectTable

      colors = ~w(red orange yellow green blue indigo violet)

      case SelectTable.new(colors) |> SelectTable.run() do
        {:ok, color} -> IO.puts("Selected: \#{color}")
        :cancelled -> IO.puts("Cancelled")
      end

  ## Keyboard Controls

  - `Left` / `h` / `Shift+Tab` - Move cursor left
  - `Down` / `j` - Move cursor down
  - `Up` / `k` - Move cursor up
  - `Right` / `l` / `Tab` - Move cursor right
  - `Enter` / `Space` - Confirm selection
  - `Escape` / `q` - Cancel selection
  - `Home` / `g` - Jump to first item
  - `End` / `G` - Jump to last item

  ## Theme Integration

  When a global theme is set and `use_theme` is enabled (default),
  the table automatically uses theme colors for cursor highlighting and borders.
  """

  defstruct items: [],
            cursor_index: 0,
            columns: :auto,
            cursor_style: nil,
            item_style: nil,
            border: :rounded,
            use_theme: true,
            show_help: true,
            help_style: nil

  @type item :: String.t() | {String.t(), term()}

  @type t :: %__MODULE__{
          items: [item()],
          cursor_index: non_neg_integer(),
          columns: :auto | pos_integer(),
          cursor_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          border: atom() | nil,
          use_theme: boolean(),
          show_help: boolean(),
          help_style: Esc.Style.t() | nil
        }

  # Cursor adds [] around text = 2 chars, plus 1 space padding each side = 4 total extra
  @cursor_overhead 4

  # ===========================================================================
  # Core Functions
  # ===========================================================================

  @doc """
  Creates a new select table with the given items.

  Items can be strings or `{display_text, return_value}` tuples.
  """
  @spec new([item()]) :: t()
  def new(items \\ []) when is_list(items) do
    %__MODULE__{items: items}
  end

  @doc """
  Adds an item to the select table.
  """
  @spec item(t(), item()) :: t()
  def item(%__MODULE__{} = table, item) do
    %{table | items: table.items ++ [item]}
  end

  @doc """
  Sets the number of columns.

  Use `:auto` (default) to calculate based on terminal width and item widths.
  """
  @spec columns(t(), :auto | pos_integer()) :: t()
  def columns(%__MODULE__{} = table, :auto), do: %{table | columns: :auto}

  def columns(%__MODULE__{} = table, cols) when is_integer(cols) and cols > 0 do
    %{table | columns: cols}
  end

  # ===========================================================================
  # Styling Functions
  # ===========================================================================

  @doc """
  Sets the style for the currently focused cell.
  """
  @spec cursor_style(t(), Esc.Style.t()) :: t()
  def cursor_style(%__MODULE__{} = table, style) do
    %{table | cursor_style: style}
  end

  @doc """
  Sets the style for non-focused cells.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = table, style) do
    %{table | item_style: style}
  end

  @doc """
  Sets the table border style.

  Available styles: `:normal`, `:rounded`, `:thick`, `:double`, `:ascii`, `nil` (no border)
  """
  @spec border(t(), atom() | nil) :: t()
  def border(%__MODULE__{} = table, style) do
    %{table | border: style}
  end

  @doc """
  Shows or hides the help text.
  """
  @spec show_help(t(), boolean()) :: t()
  def show_help(%__MODULE__{} = table, enabled) when is_boolean(enabled) do
    %{table | show_help: enabled}
  end

  @doc """
  Sets the style for help text.
  """
  @spec help_style(t(), Esc.Style.t()) :: t()
  def help_style(%__MODULE__{} = table, style) do
    %{table | help_style: style}
  end

  @doc """
  Enables or disables automatic theme colors.
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = table, enabled) when is_boolean(enabled) do
    %{table | use_theme: enabled}
  end

  # ===========================================================================
  # Rendering
  # ===========================================================================

  @doc """
  Renders the select table at its current state (non-interactive).
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{items: []}), do: ""

  def render(%__MODULE__{} = table) do
    {col_count, cell_width} = calculate_grid_dimensions(table)
    cursor_style = get_effective_cursor_style(table)
    item_style = table.item_style
    border_style = get_effective_border_style(table)

    # Build grid rows with styled cells
    cell_rows =
      table.items
      |> Enum.with_index()
      |> Enum.chunk_every(col_count)
      |> Enum.map(fn chunk ->
        # Pad row to full width
        padded = chunk ++ List.duplicate(nil, col_count - length(chunk))

        Enum.map(padded, fn
          nil ->
            # Empty cell - just spaces, no styling
            String.duplicate(" ", cell_width)

          {item, idx} ->
            display_text = get_display_text(item)
            is_focused = idx == table.cursor_index

            # Build cell content with brackets for focused item
            content =
              if is_focused do
                "[#{display_text}]"
              else
                " #{display_text} "
              end

            # Pad to cell width first
            padded_content = pad_to_width(content, cell_width)

            # Apply ANSI style after padding
            style = if is_focused, do: cursor_style, else: item_style
            Esc.Grid.apply_style(padded_content, style)
        end)
      end)

    # Use shared grid renderer
    table_output = Esc.Grid.render(cell_rows, cell_width, table.border, border_style)

    if table.show_help do
      help_text = build_help_text()
      help_style = get_effective_help_style(table)
      styled_help = if help_style, do: Esc.render(help_style, help_text), else: help_text
      table_output <> "\n" <> styled_help
    else
      table_output
    end
  end

  @doc """
  Runs the interactive selection loop.

  Returns `{:ok, selected_value}` when the user confirms,
  or `:cancelled` if the user presses Escape or q.
  """
  @spec run(t()) :: {:ok, term()} | :cancelled
  def run(%__MODULE__{items: []}), do: :cancelled

  def run(%__MODULE__{} = table) do
    :shell.start_interactive({:noshell, :raw})
    IO.write(hide_cursor())

    try do
      loop(table)
    after
      IO.write(show_cursor())
      :shell.start_interactive({:noshell, :cooked})
    end
  end

  # ===========================================================================
  # Private - Grid Calculation
  # ===========================================================================

  defp calculate_grid_dimensions(%__MODULE__{items: []}), do: {1, 10}

  defp calculate_grid_dimensions(%__MODULE__{columns: cols, items: items}) when is_integer(cols) do
    # Fixed columns - calculate cell width from max item
    max_item_len = items |> Enum.map(&(get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max()
    cell_width = max_item_len + @cursor_overhead
    {cols, cell_width}
  end

  defp calculate_grid_dimensions(%__MODULE__{columns: :auto, items: items, border: border}) do
    terminal_width = Esc.Table.get_terminal_width()

    # Find the longest item (using display width for emoji support)
    max_item_len = items |> Enum.map(&(get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max()

    # Cell width = item text + cursor overhead (brackets + padding)
    cell_width = max_item_len + @cursor_overhead

    # Calculate how many columns fit (with 2-char safety margin to prevent wrapping)
    col_count =
      if border do
        # With border: total = 1 + n*(cell_width + 3)
        # Subtract 2 extra for safety margin
        max(1, div(terminal_width - 3, cell_width + 3))
      else
        max(1, div(terminal_width - 2, cell_width + 2))
      end

    {col_count, cell_width}
  end

  defp pad_to_width(string, width) do
    len = Esc.Grid.display_width(string)
    if len >= width do
      string
    else
      string <> String.duplicate(" ", width - len)
    end
  end

  # ===========================================================================
  # Private - Interactive Loop
  # ===========================================================================

  defp loop(table) do
    output = render(table)
    # Simple line count - lines should never wrap with proper grid sizing
    line_count = output |> String.split("\n") |> length()

    IO.write(String.replace(output, "\n", "\r\n"))

    {col_count, _} = calculate_grid_dimensions(table)

    case read_key() do
      :left ->
        move_and_redraw(table, line_count, &move_left(&1, col_count))

      :right ->
        move_and_redraw(table, line_count, &move_right(&1, col_count))

      :up ->
        move_and_redraw(table, line_count, &move_up(&1, col_count))

      :down ->
        move_and_redraw(table, line_count, &move_down(&1, col_count))

      :home ->
        move_and_redraw(table, line_count, &move_home/1)

      :end_key ->
        move_and_redraw(table, line_count, &move_end/1)

      :enter ->
        IO.write("\r\n")
        {:ok, get_return_value(table)}

      :cancel ->
        clear_lines(line_count)
        :cancelled

      _ ->
        move_and_redraw(table, line_count, & &1)
    end
  end

  defp move_and_redraw(table, line_count, move_fn) do
    clear_lines(line_count)
    loop(move_fn.(table))
  end

  defp move_left(table, _col_count) do
    new_index = max(0, table.cursor_index - 1)
    %{table | cursor_index: new_index}
  end

  defp move_right(table, _col_count) do
    max_index = length(table.items) - 1
    new_index = min(max_index, table.cursor_index + 1)
    %{table | cursor_index: new_index}
  end

  defp move_up(table, col_count) do
    new_index = table.cursor_index - col_count

    if new_index >= 0 do
      %{table | cursor_index: new_index}
    else
      # Wrap to bottom
      row_count = ceil(length(table.items) / col_count)
      current_col = rem(table.cursor_index, col_count)
      wrapped_index = (row_count - 1) * col_count + current_col
      # Make sure we don't go past the last item
      %{table | cursor_index: min(wrapped_index, length(table.items) - 1)}
    end
  end

  defp move_down(table, col_count) do
    new_index = table.cursor_index + col_count
    max_index = length(table.items) - 1

    if new_index <= max_index do
      %{table | cursor_index: new_index}
    else
      # Wrap to top
      current_col = rem(table.cursor_index, col_count)
      %{table | cursor_index: current_col}
    end
  end

  defp move_home(table) do
    %{table | cursor_index: 0}
  end

  defp move_end(table) do
    %{table | cursor_index: length(table.items) - 1}
  end

  # ===========================================================================
  # Private - Key Reading
  # ===========================================================================

  defp read_key do
    case read_char() do
      "\e" -> read_escape_sequence()
      "\r" -> :enter
      "\n" -> :enter
      " " -> :enter
      "\t" -> :right
      "h" -> :left
      "j" -> :down
      "k" -> :up
      "l" -> :right
      "g" -> :home
      "G" -> :end_key
      "q" -> :cancel
      <<3>> -> :cancel
      :eof -> :cancel
      _ -> :unknown
    end
  end

  defp read_char, do: IO.getn("", 1)

  defp read_escape_sequence do
    case read_char() do
      "[" ->
        case read_char() do
          "A" -> :up
          "B" -> :down
          "C" -> :right
          "D" -> :left
          "Z" -> :left
          "H" -> :home
          "F" -> :end_key
          "1" ->
            case read_char() do
              "~" -> :home
              _ -> :unknown
            end
          "4" ->
            case read_char() do
              "~" -> :end_key
              _ -> :unknown
            end
          _ -> :unknown
        end

      _ -> :cancel
    end
  end

  # ===========================================================================
  # Private - ANSI
  # ===========================================================================

  defp hide_cursor, do: "\e[?25l"
  defp show_cursor, do: "\e[?25h"

  defp clear_lines(count) when count > 1 do
    IO.write("\r\e[#{count - 1}A\e[J")
  end

  defp clear_lines(_count), do: IO.write("\r\e[J")

  # ===========================================================================
  # Private - Helpers
  # ===========================================================================

  defp get_display_text({text, _value}) when is_binary(text), do: text
  defp get_display_text(text) when is_binary(text), do: text

  defp get_return_value(%__MODULE__{items: items, cursor_index: idx}) do
    case Enum.at(items, idx) do
      {_text, value} -> value
      text -> text
    end
  end

  defp build_help_text do
    "hjkl/arrows: navigate | Enter: select | q: cancel"
  end

  # ===========================================================================
  # Private - Theme & Styling
  # ===========================================================================

  defp get_effective_cursor_style(table) do
    case {table.cursor_style, table.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :header))
        |> Esc.bold()

      _ ->
        Esc.style() |> Esc.bold()
    end
  end

  defp get_effective_border_style(table) do
    case {table.use_theme, Esc.get_theme()} do
      {true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end

  defp get_effective_help_style(table) do
    case {table.help_style, table.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
