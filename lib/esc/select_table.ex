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
  - `Escape` / `q` - Cancel selection (or exit filter mode)
  - `Home` / `g` - Jump to first item
  - `End` / `G` - Jump to last item
  - `/` - Enter filter mode
  - `Ctrl+F` / `]` - Next page
  - `Ctrl+B` / `[` - Previous page

  ## Filtering

  Press `/` to enter filter mode and type to filter items. Supports glob-style
  wildcards with `*` (e.g., `*.md`, `test*`, `*api*`).

  Escape exits filter mode; press again to clear the filter.

  ## Theme Integration

  When a global theme is set and `use_theme` is enabled (default),
  the table automatically uses theme colors for cursor highlighting and borders.
  """

  @default_page_size 100

  defstruct items: [],
            cursor_index: 0,
            columns: :auto,
            cursor_style: nil,
            item_style: nil,
            border: :rounded,
            use_theme: true,
            show_help: true,
            help_style: nil,
            filter_mode: false,
            filter_text: "",
            filter_style: nil,
            page_size: @default_page_size,
            current_page: 0

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
          help_style: Esc.Style.t() | nil,
          filter_mode: boolean(),
          filter_text: String.t(),
          filter_style: Esc.Style.t() | nil,
          page_size: non_neg_integer() | nil,
          current_page: non_neg_integer()
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

  @doc """
  Sets the style for the filter input line.
  """
  @spec filter_style(t(), Esc.Style.t()) :: t()
  def filter_style(%__MODULE__{} = table, style) do
    %{table | filter_style: style}
  end

  @doc """
  Sets the number of items displayed per page.

  Default is 100 items per page. Set to 0 or nil to disable pagination.
  """
  @spec page_size(t(), non_neg_integer() | nil) :: t()
  def page_size(%__MODULE__{} = table, size) when is_nil(size) or size >= 0 do
    %{table | page_size: size}
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
    # Get filtered items then paginate
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    page_items = Enum.map(page_indices, &Enum.at(table.items, &1))
    total_pages = Esc.Filter.total_pages(table.items, table.filter_text, table.page_size)

    # Calculate grid dimensions based on page items
    {col_count, cell_width} = calculate_grid_dimensions_for_items(page_items, table)
    cursor_style = get_effective_cursor_style(table)
    item_style = table.item_style
    border_style = get_effective_border_style(table)
    filter_style = get_effective_filter_style(table)

    # Find cursor position in page indices
    cursor_pos_in_page = Enum.find_index(page_indices, &(&1 == table.cursor_index))

    # Build grid rows with styled cells
    cell_rows =
      page_items
      |> Enum.with_index()
      |> Enum.chunk_every(col_count)
      |> Enum.map(fn chunk ->
        # Pad row to full width
        padded = chunk ++ List.duplicate(nil, col_count - length(chunk))

        Enum.map(padded, fn
          nil ->
            # Empty cell - just spaces, no styling
            String.duplicate(" ", cell_width)

          {item, pos_in_page} ->
            display_text = Esc.Filter.get_display_text(item)
            is_focused = pos_in_page == cursor_pos_in_page

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
    table_output =
      if length(page_items) == 0 do
        "(no matches)"
      else
        Esc.Grid.render(cell_rows, cell_width, table.border, border_style)
      end

    # Build header line with filter and/or pagination
    header_parts = []

    header_parts =
      if table.filter_mode or table.filter_text != "" do
        filter_line = Esc.Filter.render_filter_input(
          table.filter_text,
          table.filter_mode,
          prompt_style: filter_style,
          match_count: {length(filtered_indices), length(table.items)},
          count_style: filter_style
        )
        header_parts ++ [filter_line]
      else
        header_parts
      end

    header_parts =
      if total_pages > 1 do
        pagination = Esc.Filter.render_pagination(table.current_page, total_pages, style: filter_style)
        header_parts ++ [pagination]
      else
        header_parts
      end

    output_with_header =
      case header_parts do
        [] -> table_output
        parts -> Enum.join(parts, " ") <> "\n\n" <> table_output
      end

    if table.show_help do
      help_text = build_help_text()
      help_style = get_effective_help_style(table)
      styled_help = if help_style, do: Esc.render(help_style, help_text), else: help_text
      output_with_header <> "\n" <> styled_help
    else
      output_with_header
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

  defp calculate_grid_dimensions_for_items([], _table), do: {1, 10}

  defp calculate_grid_dimensions_for_items(items, %__MODULE__{columns: cols}) when is_integer(cols) do
    # Fixed columns - calculate cell width from max item
    max_item_len = items |> Enum.map(&(Esc.Filter.get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max(fn -> 0 end)
    cell_width = max(max_item_len + @cursor_overhead, 4)
    {cols, cell_width}
  end

  defp calculate_grid_dimensions_for_items(items, %__MODULE__{columns: :auto, border: border}) do
    terminal_width = Esc.Table.get_terminal_width()

    # Find the longest item (using display width for emoji support)
    max_item_len = items |> Enum.map(&(Esc.Filter.get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max(fn -> 0 end)

    # Cell width = item text + cursor overhead (brackets + padding)
    cell_width = max(max_item_len + @cursor_overhead, 4)

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

    # Read input - behavior depends on filter mode
    if table.filter_mode do
      handle_filter_mode_input(table, line_count)
    else
      handle_normal_mode_input(table, line_count)
    end
  end

  defp handle_normal_mode_input(table, line_count) do
    # Get page items for navigation
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    page_items = Enum.map(page_indices, &Enum.at(table.items, &1))
    {col_count, _} = calculate_grid_dimensions_for_items(page_items, table)

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

      :page_forward ->
        move_and_redraw(table, line_count, &next_page/1)

      :page_backward ->
        move_and_redraw(table, line_count, &prev_page/1)

      :filter ->
        move_and_redraw(table, line_count, &enter_filter_mode/1)

      :enter ->
        # Make sure cursor is on a valid page item
        if table.cursor_index in page_indices do
          IO.write("\r\n")
          {:ok, get_return_value(table)}
        else
          move_and_redraw(table, line_count, & &1)
        end

      :cancel ->
        if table.filter_text != "" do
          move_and_redraw(table, line_count, &clear_filter/1)
        else
          clear_lines(line_count)
          :cancelled
        end

      _ ->
        move_and_redraw(table, line_count, & &1)
    end
  end

  defp handle_filter_mode_input(table, line_count) do
    case read_filter_key() do
      :escape ->
        if table.filter_text == "" do
          clear_lines(line_count)
          :cancelled
        else
          move_and_redraw(table, line_count, &exit_filter_mode/1)
        end

      :enter ->
        move_and_redraw(table, line_count, &exit_filter_mode/1)

      :backspace ->
        move_and_redraw(table, line_count, &delete_filter_char/1)

      :clear_line ->
        move_and_redraw(table, line_count, fn t -> %{t | filter_text: ""} end)

      {:char, char} ->
        move_and_redraw(table, line_count, &add_filter_char(&1, char))

      _ ->
        move_and_redraw(table, line_count, & &1)
    end
  end

  defp enter_filter_mode(table) do
    %{table | filter_mode: true}
  end

  defp exit_filter_mode(table) do
    table = %{table | filter_mode: false}
    ensure_valid_cursor(table)
  end

  defp clear_filter(table) do
    %{table | filter_text: "", cursor_index: 0, current_page: 0}
  end

  defp add_filter_char(table, char) do
    new_filter = table.filter_text <> char
    table = %{table | filter_text: new_filter, current_page: 0}
    ensure_valid_cursor(table)
  end

  defp delete_filter_char(%{filter_text: ""} = table), do: table
  defp delete_filter_char(table) do
    new_filter = String.slice(table.filter_text, 0..-2//1)
    %{table | filter_text: new_filter}
  end

  defp ensure_valid_cursor(table) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)

    if table.cursor_index in filtered_indices do
      table
    else
      case filtered_indices do
        [first | _] -> %{table | cursor_index: first}
        [] -> table
      end
    end
  end

  defp move_and_redraw(table, line_count, move_fn) do
    clear_lines(line_count)
    loop(move_fn.(table))
  end

  defp move_left(table, _col_count) do
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == table.cursor_index)) || 0

    if current_pos == 0 do
      # At start of page - go to previous page
      if table.current_page > 0 do
        new_page = table.current_page - 1
        new_page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, new_page)
        new_index = List.last(new_page_indices) || table.cursor_index
        %{table | cursor_index: new_index, current_page: new_page}
      else
        table
      end
    else
      new_index = Enum.at(page_indices, current_pos - 1) || table.cursor_index
      %{table | cursor_index: new_index}
    end
  end

  defp move_right(table, _col_count) do
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == table.cursor_index)) || 0
    max_pos = length(page_indices) - 1

    if current_pos == max_pos do
      # At end of page - go to next page
      total_pages = Esc.Filter.total_pages(table.items, table.filter_text, table.page_size)
      if table.current_page < total_pages - 1 do
        new_page = table.current_page + 1
        new_page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, new_page)
        new_index = List.first(new_page_indices) || table.cursor_index
        %{table | cursor_index: new_index, current_page: new_page}
      else
        table
      end
    else
      new_index = Enum.at(page_indices, current_pos + 1) || table.cursor_index
      %{table | cursor_index: new_index}
    end
  end

  defp move_up(table, col_count) do
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == table.cursor_index)) || 0
    new_pos = current_pos - col_count

    if new_pos >= 0 do
      new_index = Enum.at(page_indices, new_pos) || table.cursor_index
      %{table | cursor_index: new_index}
    else
      # At top of grid - wrap within current page
      row_count = ceil(length(page_indices) / col_count)
      current_col = rem(current_pos, col_count)
      wrapped_pos = (row_count - 1) * col_count + current_col
      wrapped_pos = min(wrapped_pos, length(page_indices) - 1)
      new_index = Enum.at(page_indices, wrapped_pos) || table.cursor_index
      %{table | cursor_index: new_index}
    end
  end

  defp move_down(table, col_count) do
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, table.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == table.cursor_index)) || 0
    new_pos = current_pos + col_count
    max_pos = length(page_indices) - 1

    if new_pos <= max_pos do
      new_index = Enum.at(page_indices, new_pos) || table.cursor_index
      %{table | cursor_index: new_index}
    else
      # At bottom of grid - wrap within current page
      new_pos = rem(current_pos, col_count)
      new_index = Enum.at(page_indices, new_pos) || table.cursor_index
      %{table | cursor_index: new_index}
    end
  end

  defp move_home(table) do
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, 0)
    new_index = List.first(page_indices) || 0
    %{table | cursor_index: new_index, current_page: 0}
  end

  defp move_end(table) do
    total_pages = Esc.Filter.total_pages(table.items, table.filter_text, table.page_size)
    last_page = total_pages - 1
    page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, last_page)
    new_index = List.last(page_indices) || length(table.items) - 1
    %{table | cursor_index: new_index, current_page: last_page}
  end

  defp next_page(table) do
    total_pages = Esc.Filter.total_pages(table.items, table.filter_text, table.page_size)
    if table.current_page < total_pages - 1 do
      new_page = table.current_page + 1
      page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, new_page)
      new_index = List.first(page_indices) || table.cursor_index
      %{table | current_page: new_page, cursor_index: new_index}
    else
      table
    end
  end

  defp prev_page(table) do
    if table.current_page > 0 do
      new_page = table.current_page - 1
      page_indices = Esc.Filter.page_indices(table.items, table.filter_text, table.page_size, new_page)
      new_index = List.first(page_indices) || table.cursor_index
      %{table | current_page: new_page, cursor_index: new_index}
    else
      table
    end
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
      "/" -> :filter
      "\t" -> :right
      "h" -> :left
      "j" -> :down
      "k" -> :up
      "l" -> :right
      "g" -> :home
      "G" -> :end_key
      "]" -> :page_forward
      "[" -> :page_backward
      <<6>> -> :page_forward   # Ctrl+F
      <<2>> -> :page_backward  # Ctrl+B
      "q" -> :cancel
      <<3>> -> :cancel
      :eof -> :cancel
      _ -> :unknown
    end
  end

  defp read_filter_key do
    case read_char() do
      "\e" -> :escape
      "\r" -> :enter
      "\n" -> :enter
      <<127>> -> :backspace
      <<8>> -> :backspace
      <<21>> -> :clear_line
      <<3>> -> :escape
      :eof -> :escape
      char when is_binary(char) ->
        if String.printable?(char) and String.length(char) == 1 do
          {:char, char}
        else
          :unknown
        end
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

  defp get_effective_filter_style(table) do
    case {table.filter_style, table.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
