defmodule Esc.MultiSelectTable do
  @moduledoc """
  Interactive table-based multi-selection for terminal applications.

  MultiSelectTable displays items in a grid layout and allows users to navigate
  with arrow keys (or h/j/k/l), toggle selections with Space, and confirm with Enter.

  ## Example

      alias Esc.MultiSelectTable

      tags = ~w(elixir phoenix ecto liveview tailwind alpine docker kubernetes)

      case MultiSelectTable.new(tags) |> MultiSelectTable.run() do
        {:ok, selected} -> IO.puts("Selected: \#{Enum.join(selected, ", ")}")
        :cancelled -> IO.puts("Cancelled")
      end

  ## Keyboard Controls

  - `Left` / `h` / `Shift+Tab` - Move cursor left
  - `Down` / `j` - Move cursor down
  - `Up` / `k` - Move cursor up
  - `Right` / `l` / `Tab` - Move cursor right
  - `Space` - Toggle selection on current item
  - `Enter` - Confirm selections (if minimum met)
  - `Escape` / `q` - Cancel selection (or exit filter mode)
  - `Home` / `g` - Jump to first item
  - `End` / `G` - Jump to last item
  - `a` - Select all visible items (filtered items only when filtering)
  - `n` - Clear selections on visible items (filtered items only when filtering)
  - `/` - Enter filter mode

  ## Filtering

  Press `/` to enter filter mode and type to filter items. Supports glob-style
  wildcards with `*` (e.g., `*.md`, `test*`, `*api*`).

  When filtering is active, `a` and `n` only affect the displayed items.
  Escape exits filter mode; press again to clear the filter.

  ## Theme Integration

  When a global theme is set and `use_theme` is enabled (default),
  the table automatically uses theme colors for cursor, selections, and borders.
  """

  defstruct items: [],
            cursor_index: 0,
            selected_indices: MapSet.new(),
            columns: :auto,
            cursor_style: nil,
            item_style: nil,
            selected_style: nil,
            selected_marker: "*",
            border: :rounded,
            use_theme: true,
            min_selections: 0,
            max_selections: nil,
            show_help: true,
            help_style: nil,
            filter_mode: false,
            filter_text: "",
            filter_style: nil

  @type item :: String.t() | {String.t(), term()}

  @type t :: %__MODULE__{
          items: [item()],
          cursor_index: non_neg_integer(),
          selected_indices: MapSet.t(non_neg_integer()),
          columns: :auto | pos_integer(),
          cursor_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          selected_style: Esc.Style.t() | nil,
          selected_marker: String.t(),
          border: atom() | nil,
          use_theme: boolean(),
          min_selections: non_neg_integer(),
          max_selections: non_neg_integer() | nil,
          show_help: boolean(),
          help_style: Esc.Style.t() | nil,
          filter_mode: boolean(),
          filter_text: String.t(),
          filter_style: Esc.Style.t() | nil
        }

  # Cursor adds [] around text = 2 chars, marker = 1 char, plus padding = 5 total extra
  @cursor_overhead 5

  # ===========================================================================
  # Core Functions
  # ===========================================================================

  @doc """
  Creates a new multi-select table with the given items.

  Items can be strings or `{display_text, return_value}` tuples.
  """
  @spec new([item()]) :: t()
  def new(items \\ []) when is_list(items) do
    %__MODULE__{items: items}
  end

  @doc """
  Adds an item to the multi-select table.
  """
  @spec item(t(), item()) :: t()
  def item(%__MODULE__{} = table, item) do
    %{table | items: table.items ++ [item]}
  end

  @doc """
  Pre-selects items by index or value.
  """
  @spec preselect(t(), [non_neg_integer()] | [term()]) :: t()
  def preselect(%__MODULE__{} = table, selections) when is_list(selections) do
    indices =
      selections
      |> Enum.flat_map(fn selection ->
        cond do
          is_integer(selection) and selection >= 0 ->
            [selection]

          true ->
            table.items
            |> Enum.with_index()
            |> Enum.find_value([], fn {item, idx} ->
              if get_return_value_for_item(item) == selection, do: [idx], else: nil
            end)
        end
      end)
      |> Enum.filter(&(&1 < length(table.items)))
      |> MapSet.new()

    %{table | selected_indices: MapSet.union(table.selected_indices, indices)}
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
  Sets the style for non-focused, non-selected cells.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = table, style) do
    %{table | item_style: style}
  end

  @doc """
  Sets the style for selected cells (not currently focused).
  """
  @spec selected_style(t(), Esc.Style.t()) :: t()
  def selected_style(%__MODULE__{} = table, style) do
    %{table | selected_style: style}
  end

  @doc """
  Sets the marker shown in selected cells.

  Default is `"*"`.
  """
  @spec selected_marker(t(), String.t()) :: t()
  def selected_marker(%__MODULE__{} = table, marker) when is_binary(marker) do
    %{table | selected_marker: marker}
  end

  @doc """
  Sets the table border style.
  """
  @spec border(t(), atom() | nil) :: t()
  def border(%__MODULE__{} = table, style) do
    %{table | border: style}
  end

  # ===========================================================================
  # Selection Constraints
  # ===========================================================================

  @doc """
  Sets minimum required selections.
  """
  @spec min_selections(t(), non_neg_integer()) :: t()
  def min_selections(%__MODULE__{} = table, min) when is_integer(min) and min >= 0 do
    %{table | min_selections: min}
  end

  @doc """
  Sets maximum allowed selections.
  """
  @spec max_selections(t(), non_neg_integer() | nil) :: t()
  def max_selections(%__MODULE__{} = table, max)
      when is_nil(max) or (is_integer(max) and max >= 0) do
    %{table | max_selections: max}
  end

  # ===========================================================================
  # Help & Theme
  # ===========================================================================

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

  # ===========================================================================
  # Rendering
  # ===========================================================================

  @doc """
  Renders the multi-select table at its current state (non-interactive).
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{items: []}), do: ""

  def render(%__MODULE__{} = table) do
    # Get filtered items
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    filtered_items = Enum.map(filtered_indices, &Enum.at(table.items, &1))

    # Calculate grid dimensions based on filtered items
    {col_count, cell_width} = calculate_grid_dimensions_for_items(filtered_items, table)
    marker = table.selected_marker
    cursor_style = get_effective_cursor_style(table)
    selected_style = get_effective_selected_style(table)
    item_style = table.item_style
    border_style = get_effective_border_style(table)

    # Find cursor position in filtered list
    cursor_pos_in_filtered = Enum.find_index(filtered_indices, &(&1 == table.cursor_index))

    # Build grid rows with styled cells
    cell_rows =
      filtered_items
      |> Enum.with_index()
      |> Enum.chunk_every(col_count)
      |> Enum.map(fn chunk ->
        # Pad row to full width
        padded = chunk ++ List.duplicate(nil, col_count - length(chunk))

        Enum.map(padded, fn
          nil ->
            # Empty cell
            String.duplicate(" ", cell_width)

          {item, pos_in_filtered} ->
            # Get original index for selection check
            original_idx = Enum.at(filtered_indices, pos_in_filtered)
            display_text = Esc.Filter.get_display_text(item)
            is_focused = pos_in_filtered == cursor_pos_in_filtered
            is_selected = MapSet.member?(table.selected_indices, original_idx)

            # Build cell content with visual indicators
            content =
              cond do
                is_focused and is_selected ->
                  "[#{marker}#{display_text}]"

                is_focused ->
                  "[ #{display_text}]"

                is_selected ->
                  " #{marker}#{display_text} "

                true ->
                  "  #{display_text} "
              end

            # Pad to cell width first
            padded_content = pad_to_width(content, cell_width)

            # Apply ANSI style based on state
            style =
              cond do
                is_focused -> cursor_style
                is_selected -> selected_style
                true -> item_style
              end

            Esc.Grid.apply_style(padded_content, style)
        end)
      end)

    # Use shared grid renderer
    table_output =
      if length(filtered_items) == 0 do
        "(no matches)"
      else
        Esc.Grid.render(cell_rows, cell_width, table.border, border_style)
      end

    # Add filter input if filter is active or has text
    output_with_filter =
      if table.filter_mode or table.filter_text != "" do
        filter_style = get_effective_filter_style(table)
        filter_line = Esc.Filter.render_filter_input(
          table.filter_text,
          table.filter_mode,
          prompt_style: filter_style,
          match_count: {length(filtered_indices), length(table.items)},
          count_style: filter_style
        )
        filter_line <> "\n\n" <> table_output
      else
        table_output
      end

    if table.show_help do
      help_text = build_help_text(table)
      help_style = get_effective_help_style(table)
      styled_help = if help_style, do: Esc.render(help_style, help_text), else: help_text
      output_with_filter <> "\n" <> styled_help
    else
      output_with_filter
    end
  end

  @doc """
  Runs the interactive multi-selection loop.

  Returns `{:ok, selected_values}` when the user confirms,
  or `:cancelled` if the user presses Escape or q.
  """
  @spec run(t()) :: {:ok, [term()]} | :cancelled
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
    max_item_len = items |> Enum.map(&(Esc.Filter.get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max(fn -> 0 end)
    cell_width = max(max_item_len + @cursor_overhead, 4)
    {cols, cell_width}
  end

  defp calculate_grid_dimensions_for_items(items, %__MODULE__{columns: :auto, border: border}) do
    terminal_width = Esc.Table.get_terminal_width()

    # Use display_width for emoji/CJK support
    max_item_len = items |> Enum.map(&(Esc.Filter.get_display_text(&1) |> Esc.Grid.display_width())) |> Enum.max(fn -> 0 end)
    cell_width = max(max_item_len + @cursor_overhead, 4)

    # Calculate how many columns fit (with 2-char safety margin to prevent wrapping)
    col_count =
      if border do
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
    # Get filtered items for navigation
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    filtered_items = Enum.map(filtered_indices, &Enum.at(table.items, &1))
    {col_count, _} = calculate_grid_dimensions_for_items(filtered_items, table)

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

      :toggle ->
        move_and_redraw(table, line_count, &toggle_selection/1)

      :select_all ->
        move_and_redraw(table, line_count, &select_all/1)

      :select_none ->
        move_and_redraw(table, line_count, &select_none/1)

      :filter ->
        move_and_redraw(table, line_count, &enter_filter_mode/1)

      :enter ->
        if can_submit?(table) do
          IO.write("\r\n")
          {:ok, get_selected_values(table)}
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
    %{table | filter_text: "", cursor_index: 0}
  end

  defp add_filter_char(table, char) do
    new_filter = table.filter_text <> char
    table = %{table | filter_text: new_filter}
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
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == table.cursor_index)) || 0
    new_pos = max(0, current_pos - 1)
    new_index = Enum.at(filtered_indices, new_pos) || table.cursor_index
    %{table | cursor_index: new_index}
  end

  defp move_right(table, _col_count) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == table.cursor_index)) || 0
    max_pos = length(filtered_indices) - 1
    new_pos = min(max_pos, current_pos + 1)
    new_index = Enum.at(filtered_indices, new_pos) || table.cursor_index
    %{table | cursor_index: new_index}
  end

  defp move_up(table, col_count) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == table.cursor_index)) || 0
    new_pos = current_pos - col_count

    new_pos =
      if new_pos >= 0 do
        new_pos
      else
        row_count = ceil(length(filtered_indices) / col_count)
        current_col = rem(current_pos, col_count)
        wrapped_pos = (row_count - 1) * col_count + current_col
        min(wrapped_pos, length(filtered_indices) - 1)
      end

    new_index = Enum.at(filtered_indices, new_pos) || table.cursor_index
    %{table | cursor_index: new_index}
  end

  defp move_down(table, col_count) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == table.cursor_index)) || 0
    new_pos = current_pos + col_count
    max_pos = length(filtered_indices) - 1

    new_pos =
      if new_pos <= max_pos do
        new_pos
      else
        rem(current_pos, col_count)
      end

    new_index = Enum.at(filtered_indices, new_pos) || table.cursor_index
    %{table | cursor_index: new_index}
  end

  defp move_home(table) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    new_index = List.first(filtered_indices) || 0
    %{table | cursor_index: new_index}
  end

  defp move_end(table) do
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    new_index = List.last(filtered_indices) || length(table.items) - 1
    %{table | cursor_index: new_index}
  end

  defp toggle_selection(table) do
    idx = table.cursor_index
    currently_selected = MapSet.member?(table.selected_indices, idx)

    cond do
      currently_selected ->
        %{table | selected_indices: MapSet.delete(table.selected_indices, idx)}

      at_max_selections?(table) ->
        table

      true ->
        %{table | selected_indices: MapSet.put(table.selected_indices, idx)}
    end
  end

  defp select_all(table) do
    # Only select filtered/displayed items
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    max = table.max_selections
    current = table.selected_indices

    # Calculate how many more we can select
    can_add = if is_nil(max), do: length(filtered_indices), else: max - MapSet.size(current)

    additional =
      filtered_indices
      |> Enum.reject(&MapSet.member?(current, &1))
      |> Enum.take(max(0, can_add))
      |> MapSet.new()

    %{table | selected_indices: MapSet.union(current, additional)}
  end

  defp select_none(table) do
    # Only deselect filtered/displayed items
    filtered_indices = Esc.Filter.matching_indices(table.items, table.filter_text)
    filtered_set = MapSet.new(filtered_indices)
    remaining = MapSet.difference(table.selected_indices, filtered_set)
    %{table | selected_indices: remaining}
  end

  defp at_max_selections?(%__MODULE__{max_selections: nil}), do: false

  defp at_max_selections?(table) do
    MapSet.size(table.selected_indices) >= table.max_selections
  end

  defp can_submit?(table) do
    MapSet.size(table.selected_indices) >= table.min_selections
  end

  # ===========================================================================
  # Private - Key Reading
  # ===========================================================================

  defp read_key do
    case read_char() do
      "\e" -> read_escape_sequence()
      "\r" -> :enter
      "\n" -> :enter
      " " -> :toggle
      "/" -> :filter
      "\t" -> :right
      "h" -> :left
      "j" -> :down
      "k" -> :up
      "l" -> :right
      "g" -> :home
      "G" -> :end_key
      "a" -> :select_all
      "n" -> :select_none
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

  defp get_return_value_for_item({_text, value}), do: value
  defp get_return_value_for_item(text) when is_binary(text), do: text

  defp get_selected_values(table) do
    table.selected_indices
    |> MapSet.to_list()
    |> Enum.sort()
    |> Enum.map(fn idx ->
      item = Enum.at(table.items, idx)
      get_return_value_for_item(item)
    end)
  end

  defp build_help_text(table) do
    selected_count = MapSet.size(table.selected_indices)
    min = table.min_selections

    toggle_text =
      if at_max_selections?(table) do
        "Space: toggle (max)"
      else
        "Space: toggle"
      end

    confirm_text =
      cond do
        selected_count < min ->
          needed = min - selected_count
          "Enter: confirm (#{needed} more)"

        true ->
          "Enter: confirm (#{selected_count})"
      end

    "hjkl/arrows: nav | #{toggle_text} | #{confirm_text} | a/n: all/none | q: cancel"
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

  defp get_effective_selected_style(table) do
    case {table.selected_style, table.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :success))

      _ ->
        nil
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
