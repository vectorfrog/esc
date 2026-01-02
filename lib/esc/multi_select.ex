defmodule Esc.MultiSelect do
  @moduledoc """
  Interactive multi-selection list for terminal applications.

  MultiSelect provides a navigable list where users can move a cursor with arrow keys,
  toggle selections with Space, and confirm their choices with Enter.

  ## Example

      alias Esc.MultiSelect

      case MultiSelect.new(["Option 1", "Option 2", "Option 3"]) |> MultiSelect.run() do
        {:ok, selected} -> IO.puts("You selected: \#{inspect(selected)}")
        :cancelled -> IO.puts("Selection cancelled")
      end

  ## Items with Custom Return Values

  Items can be tuples of `{display_text, return_value}`:

      MultiSelect.new([
        {"Production", :prod},
        {"Staging", :staging},
        {"Development", :dev}
      ])
      |> MultiSelect.run()
      # Returns {:ok, [:prod, :dev]} when those items are selected

  ## Keyboard Controls

  - `Up` / `k` - Move cursor up
  - `Down` / `j` - Move cursor down
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

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default),
  the multi-select automatically uses theme colors:

  - Cursor: theme `:emphasis` color
  - Focused item: theme `:header` color
  - Selected marker: theme `:success` color
  - Unselected marker: theme `:muted` color
  - Help text: theme `:muted` color

  Explicit styles override theme colors. Use `use_theme(multi_select, false)` to disable.
  """

  defstruct items: [],
            cursor_index: 0,
            selected_indices: MapSet.new(),
            cursor: "> ",
            cursor_style: nil,
            selected_marker: "[x] ",
            unselected_marker: "[ ] ",
            selected_marker_style: nil,
            unselected_marker_style: nil,
            focused_style: nil,
            item_style: nil,
            selected_item_style: nil,
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
          cursor: String.t(),
          cursor_style: Esc.Style.t() | nil,
          selected_marker: String.t(),
          unselected_marker: String.t(),
          selected_marker_style: Esc.Style.t() | nil,
          unselected_marker_style: Esc.Style.t() | nil,
          focused_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          selected_item_style: Esc.Style.t() | nil,
          use_theme: boolean(),
          min_selections: non_neg_integer(),
          max_selections: non_neg_integer() | nil,
          show_help: boolean(),
          help_style: Esc.Style.t() | nil,
          filter_mode: boolean(),
          filter_text: String.t(),
          filter_style: Esc.Style.t() | nil
        }

  # ===========================================================================
  # Core Functions
  # ===========================================================================

  @doc """
  Creates a new multi-select with the given items.

  Items can be strings or `{display_text, return_value}` tuples.

  ## Examples

      MultiSelect.new(["Option 1", "Option 2", "Option 3"])

      MultiSelect.new([
        {"Enable logging", :logging},
        {"Enable metrics", :metrics}
      ])
  """
  @spec new([item()]) :: t()
  def new(items \\ []) when is_list(items) do
    %__MODULE__{items: items}
  end

  @doc """
  Adds an item to the multi-select list.
  """
  @spec item(t(), item()) :: t()
  def item(%__MODULE__{} = multi_select, item) do
    %{multi_select | items: multi_select.items ++ [item]}
  end

  @doc """
  Pre-selects items by index or value.

  ## Examples

      # By indices
      MultiSelect.new(items) |> MultiSelect.preselect([0, 2])

      # By return values
      MultiSelect.new([{"A", :a}, {"B", :b}]) |> MultiSelect.preselect([:a])
  """
  @spec preselect(t(), [non_neg_integer()] | [term()]) :: t()
  def preselect(%__MODULE__{} = multi_select, selections) when is_list(selections) do
    indices =
      selections
      |> Enum.flat_map(fn selection ->
        cond do
          is_integer(selection) and selection >= 0 ->
            [selection]

          true ->
            # Try to find by value
            multi_select.items
            |> Enum.with_index()
            |> Enum.find_value([], fn {item, idx} ->
              if get_return_value_for_item(item) == selection, do: [idx], else: nil
            end)
        end
      end)
      |> Enum.filter(&(&1 < length(multi_select.items)))
      |> MapSet.new()

    %{multi_select | selected_indices: MapSet.union(multi_select.selected_indices, indices)}
  end

  # ===========================================================================
  # Cursor Customization
  # ===========================================================================

  @doc """
  Sets the cursor string shown next to the focused item.

  Default is `"> "`.
  """
  @spec cursor(t(), String.t()) :: t()
  def cursor(%__MODULE__{} = multi_select, cursor) when is_binary(cursor) do
    %{multi_select | cursor: cursor}
  end

  @doc """
  Sets the style for the cursor.
  """
  @spec cursor_style(t(), Esc.Style.t()) :: t()
  def cursor_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | cursor_style: style}
  end

  # ===========================================================================
  # Selection Markers
  # ===========================================================================

  @doc """
  Sets both selected and unselected markers.

  Both markers should have the same display width for proper alignment.

  ## Examples

      MultiSelect.new(items) |> MultiSelect.markers("[x] ", "[ ] ")  # Checkbox style
      MultiSelect.new(items) |> MultiSelect.markers("* ", "  ")      # Asterisk style
  """
  @spec markers(t(), String.t(), String.t()) :: t()
  def markers(%__MODULE__{} = multi_select, selected, unselected)
      when is_binary(selected) and is_binary(unselected) do
    %{multi_select | selected_marker: selected, unselected_marker: unselected}
  end

  @doc """
  Sets the marker shown for selected items.

  Default is `"[x] "`.
  """
  @spec selected_marker(t(), String.t()) :: t()
  def selected_marker(%__MODULE__{} = multi_select, marker) when is_binary(marker) do
    %{multi_select | selected_marker: marker}
  end

  @doc """
  Sets the marker shown for unselected items.

  Default is `"[ ] "`.
  """
  @spec unselected_marker(t(), String.t()) :: t()
  def unselected_marker(%__MODULE__{} = multi_select, marker) when is_binary(marker) do
    %{multi_select | unselected_marker: marker}
  end

  @doc """
  Sets styles for selection markers.
  """
  @spec marker_styles(t(), Esc.Style.t() | nil, Esc.Style.t() | nil) :: t()
  def marker_styles(%__MODULE__{} = multi_select, selected_style, unselected_style) do
    %{multi_select | selected_marker_style: selected_style, unselected_marker_style: unselected_style}
  end

  # ===========================================================================
  # Item Styling
  # ===========================================================================

  @doc """
  Sets the style for the currently focused item text.
  """
  @spec focused_style(t(), Esc.Style.t()) :: t()
  def focused_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | focused_style: style}
  end

  @doc """
  Sets the style for non-focused, non-selected items.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | item_style: style}
  end

  @doc """
  Sets the style for selected (but not currently focused) item text.
  """
  @spec selected_item_style(t(), Esc.Style.t()) :: t()
  def selected_item_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | selected_item_style: style}
  end

  # ===========================================================================
  # Selection Constraints
  # ===========================================================================

  @doc """
  Sets minimum required selections.

  Submit is blocked until minimum is met.
  """
  @spec min_selections(t(), non_neg_integer()) :: t()
  def min_selections(%__MODULE__{} = multi_select, min) when is_integer(min) and min >= 0 do
    %{multi_select | min_selections: min}
  end

  @doc """
  Sets maximum allowed selections.

  Space toggle is ignored when adding would exceed limit.
  """
  @spec max_selections(t(), non_neg_integer() | nil) :: t()
  def max_selections(%__MODULE__{} = multi_select, max)
      when is_nil(max) or (is_integer(max) and max >= 0) do
    %{multi_select | max_selections: max}
  end

  # ===========================================================================
  # Help Text
  # ===========================================================================

  @doc """
  Shows or hides the help text at bottom.
  """
  @spec show_help(t(), boolean()) :: t()
  def show_help(%__MODULE__{} = multi_select, enabled) when is_boolean(enabled) do
    %{multi_select | show_help: enabled}
  end

  @doc """
  Sets the style for help text.
  """
  @spec help_style(t(), Esc.Style.t()) :: t()
  def help_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | help_style: style}
  end

  # ===========================================================================
  # Theme
  # ===========================================================================

  @doc """
  Enables or disables automatic theme colors.

  When enabled (default), the multi-select uses theme colors for:
  - Cursor (`:emphasis` color)
  - Focused item (`:header` color)
  - Selected marker (`:success` color)
  - Unselected marker (`:muted` color)
  - Help text (`:muted` color)

  Explicit styles override theme colors.
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = multi_select, enabled) when is_boolean(enabled) do
    %{multi_select | use_theme: enabled}
  end

  @doc """
  Sets the style for the filter input line.
  """
  @spec filter_style(t(), Esc.Style.t()) :: t()
  def filter_style(%__MODULE__{} = multi_select, style) do
    %{multi_select | filter_style: style}
  end

  # ===========================================================================
  # Rendering
  # ===========================================================================

  @doc """
  Renders the multi-select list at its current state (non-interactive).

  This is useful for previewing the multi-select or for testing.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{items: []}), do: ""

  def render(%__MODULE__{} = multi_select) do
    cursor_width = String.length(multi_select.cursor)
    blank_cursor = String.duplicate(" ", cursor_width)

    # Get effective styles
    cursor_style = get_effective_cursor_style(multi_select)
    focused_style = get_effective_focused_style(multi_select)
    selected_marker_style = get_effective_selected_marker_style(multi_select)
    unselected_marker_style = get_effective_unselected_marker_style(multi_select)
    selected_item_style = get_effective_selected_item_style(multi_select)

    # Get filtered items with their original indices
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)

    items_output =
      filtered_indices
      |> Enum.map(fn idx ->
        item = Enum.at(multi_select.items, idx)
        display_text = Esc.Filter.get_display_text(item)
        is_focused = idx == multi_select.cursor_index
        is_selected = MapSet.member?(multi_select.selected_indices, idx)

        # Build cursor part
        cursor_part =
          if is_focused do
            apply_style(multi_select.cursor, cursor_style)
          else
            blank_cursor
          end

        # Build marker part
        marker_part =
          if is_selected do
            apply_style(multi_select.selected_marker, selected_marker_style)
          else
            apply_style(multi_select.unselected_marker, unselected_marker_style)
          end

        # Build text part with appropriate style
        text_style =
          cond do
            is_focused -> focused_style
            is_selected -> selected_item_style
            true -> multi_select.item_style
          end

        text_part = apply_style(display_text, text_style)

        cursor_part <> marker_part <> text_part
      end)
      |> Enum.join("\n")

    # Add filter input if filter is active or has text
    output_with_filter =
      if multi_select.filter_mode or multi_select.filter_text != "" do
        filter_style = get_effective_filter_style(multi_select)
        filter_line = Esc.Filter.render_filter_input(
          multi_select.filter_text,
          multi_select.filter_mode,
          prompt_style: filter_style,
          match_count: {length(filtered_indices), length(multi_select.items)},
          count_style: filter_style
        )
        filter_line <> "\n\n" <> items_output
      else
        items_output
      end

    if multi_select.show_help do
      help_text = build_help_text(multi_select)
      help_style = get_effective_help_style(multi_select)
      styled_help = apply_style(help_text, help_style)
      output_with_filter <> "\n\n" <> styled_help
    else
      output_with_filter
    end
  end

  @doc """
  Runs the interactive multi-selection loop.

  Returns `{:ok, selected_values}` when the user confirms,
  or `:cancelled` if the user presses Escape or q.

  For items defined as `{display_text, return_value}` tuples,
  the return_values are returned. For string items, the strings themselves are returned.
  """
  @spec run(t()) :: {:ok, [term()]} | :cancelled
  def run(%__MODULE__{items: []}), do: :cancelled

  def run(%__MODULE__{} = multi_select) do
    # OTP 28+ raw terminal mode
    :shell.start_interactive({:noshell, :raw})

    # Hide cursor
    IO.write(hide_cursor())

    try do
      loop(multi_select)
    after
      # Restore terminal state
      IO.write(show_cursor())
      :shell.start_interactive({:noshell, :cooked})
    end
  end

  # ===========================================================================
  # Private - Interactive Loop
  # ===========================================================================

  defp loop(multi_select) do
    # Render current state
    output = render(multi_select)
    line_count = length(String.split(output, "\n"))

    # In raw mode, \n doesn't return to column 0, so use \r\n
    IO.write(String.replace(output, "\n", "\r\n"))

    # Read input - behavior depends on filter mode
    if multi_select.filter_mode do
      handle_filter_mode_input(multi_select, line_count)
    else
      handle_normal_mode_input(multi_select, line_count)
    end
  end

  defp handle_normal_mode_input(multi_select, line_count) do
    case read_key() do
      :up ->
        move_and_redraw(multi_select, line_count, &move_up/1)

      :down ->
        move_and_redraw(multi_select, line_count, &move_down/1)

      :home ->
        move_and_redraw(multi_select, line_count, &move_home/1)

      :end_key ->
        move_and_redraw(multi_select, line_count, &move_end/1)

      :toggle ->
        move_and_redraw(multi_select, line_count, &toggle_selection/1)

      :select_all ->
        move_and_redraw(multi_select, line_count, &select_all/1)

      :select_none ->
        move_and_redraw(multi_select, line_count, &select_none/1)

      :filter ->
        move_and_redraw(multi_select, line_count, &enter_filter_mode/1)

      :enter ->
        if can_submit?(multi_select) do
          IO.write("\r\n")
          {:ok, get_selected_values(multi_select)}
        else
          move_and_redraw(multi_select, line_count, & &1)
        end

      :cancel ->
        if multi_select.filter_text != "" do
          move_and_redraw(multi_select, line_count, &clear_filter/1)
        else
          clear_lines(line_count)
          :cancelled
        end

      _ ->
        move_and_redraw(multi_select, line_count, & &1)
    end
  end

  defp handle_filter_mode_input(multi_select, line_count) do
    case read_filter_key() do
      :escape ->
        if multi_select.filter_text == "" do
          clear_lines(line_count)
          :cancelled
        else
          move_and_redraw(multi_select, line_count, &exit_filter_mode/1)
        end

      :enter ->
        move_and_redraw(multi_select, line_count, &exit_filter_mode/1)

      :backspace ->
        move_and_redraw(multi_select, line_count, &delete_filter_char/1)

      :clear_line ->
        move_and_redraw(multi_select, line_count, fn s -> %{s | filter_text: ""} end)

      {:char, char} ->
        move_and_redraw(multi_select, line_count, &add_filter_char(&1, char))

      _ ->
        move_and_redraw(multi_select, line_count, & &1)
    end
  end

  defp enter_filter_mode(multi_select) do
    %{multi_select | filter_mode: true}
  end

  defp exit_filter_mode(multi_select) do
    multi_select = %{multi_select | filter_mode: false}
    ensure_valid_cursor(multi_select)
  end

  defp clear_filter(multi_select) do
    %{multi_select | filter_text: "", cursor_index: 0}
  end

  defp add_filter_char(multi_select, char) do
    new_filter = multi_select.filter_text <> char
    multi_select = %{multi_select | filter_text: new_filter}
    ensure_valid_cursor(multi_select)
  end

  defp delete_filter_char(%{filter_text: ""} = multi_select), do: multi_select
  defp delete_filter_char(multi_select) do
    new_filter = String.slice(multi_select.filter_text, 0..-2//1)
    %{multi_select | filter_text: new_filter}
  end

  defp ensure_valid_cursor(multi_select) do
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)

    if multi_select.cursor_index in filtered_indices do
      multi_select
    else
      case filtered_indices do
        [first | _] -> %{multi_select | cursor_index: first}
        [] -> multi_select
      end
    end
  end

  defp move_and_redraw(multi_select, line_count, action_fn) do
    clear_lines(line_count)
    loop(action_fn.(multi_select))
  end

  defp move_up(%__MODULE__{} = multi_select) do
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == multi_select.cursor_index)) || 0
    new_pos = if current_pos == 0, do: length(filtered_indices) - 1, else: current_pos - 1
    new_index = Enum.at(filtered_indices, new_pos) || multi_select.cursor_index
    %{multi_select | cursor_index: new_index}
  end

  defp move_down(%__MODULE__{} = multi_select) do
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    current_pos = Enum.find_index(filtered_indices, &(&1 == multi_select.cursor_index)) || 0
    new_pos = if current_pos == length(filtered_indices) - 1, do: 0, else: current_pos + 1
    new_index = Enum.at(filtered_indices, new_pos) || multi_select.cursor_index
    %{multi_select | cursor_index: new_index}
  end

  defp move_home(%__MODULE__{} = multi_select) do
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    new_index = List.first(filtered_indices) || 0
    %{multi_select | cursor_index: new_index}
  end

  defp move_end(%__MODULE__{} = multi_select) do
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    new_index = List.last(filtered_indices) || length(multi_select.items) - 1
    %{multi_select | cursor_index: new_index}
  end

  defp toggle_selection(%__MODULE__{} = multi_select) do
    idx = multi_select.cursor_index
    currently_selected = MapSet.member?(multi_select.selected_indices, idx)

    cond do
      currently_selected ->
        # Always allow deselection
        %{multi_select | selected_indices: MapSet.delete(multi_select.selected_indices, idx)}

      at_max_selections?(multi_select) ->
        # Can't add more
        multi_select

      true ->
        # Add selection
        %{multi_select | selected_indices: MapSet.put(multi_select.selected_indices, idx)}
    end
  end

  defp select_all(%__MODULE__{} = multi_select) do
    # Only select filtered/displayed items
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    max = multi_select.max_selections
    current = multi_select.selected_indices

    # Calculate how many more we can select
    can_add = if is_nil(max), do: length(filtered_indices), else: max - MapSet.size(current)

    additional =
      filtered_indices
      |> Enum.reject(&MapSet.member?(current, &1))
      |> Enum.take(max(0, can_add))
      |> MapSet.new()

    %{multi_select | selected_indices: MapSet.union(current, additional)}
  end

  defp select_none(%__MODULE__{} = multi_select) do
    # Only deselect filtered/displayed items
    filtered_indices = Esc.Filter.matching_indices(multi_select.items, multi_select.filter_text)
    filtered_set = MapSet.new(filtered_indices)
    remaining = MapSet.difference(multi_select.selected_indices, filtered_set)
    %{multi_select | selected_indices: remaining}
  end

  defp at_max_selections?(%__MODULE__{max_selections: nil}), do: false

  defp at_max_selections?(%__MODULE__{} = multi_select) do
    MapSet.size(multi_select.selected_indices) >= multi_select.max_selections
  end

  defp can_submit?(%__MODULE__{} = multi_select) do
    MapSet.size(multi_select.selected_indices) >= multi_select.min_selections
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
      "j" -> :down
      "k" -> :up
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

  defp read_char do
    IO.getn("", 1)
  end

  defp read_escape_sequence do
    case read_char() do
      "[" ->
        case read_char() do
          "A" -> :up
          "B" -> :down
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

      _ ->
        :cancel
    end
  end

  # ===========================================================================
  # Private - ANSI Escape Sequences
  # ===========================================================================

  defp hide_cursor, do: "\e[?25l"
  defp show_cursor, do: "\e[?25h"

  defp clear_lines(count) when count > 1 do
    IO.write("\r\e[#{count - 1}A\e[J")
  end

  defp clear_lines(_count) do
    IO.write("\r\e[J")
  end

  # ===========================================================================
  # Private - Helpers
  # ===========================================================================

  defp get_return_value_for_item({_text, value}), do: value
  defp get_return_value_for_item(text) when is_binary(text), do: text

  defp get_selected_values(%__MODULE__{} = multi_select) do
    multi_select.selected_indices
    |> MapSet.to_list()
    |> Enum.sort()
    |> Enum.map(fn idx ->
      item = Enum.at(multi_select.items, idx)
      get_return_value_for_item(item)
    end)
  end

  defp apply_style(text, nil), do: text
  defp apply_style(text, style), do: Esc.render(style, text)

  defp build_help_text(%__MODULE__{} = multi_select) do
    selected_count = MapSet.size(multi_select.selected_indices)
    min = multi_select.min_selections

    toggle_text =
      if at_max_selections?(multi_select) do
        "space: toggle (max reached)"
      else
        "space: toggle"
      end

    confirm_text =
      cond do
        selected_count < min ->
          needed = min - selected_count
          "enter: confirm (#{needed} more needed)"

        true ->
          "enter: confirm (#{selected_count} selected)"
      end

    "#{toggle_text} | #{confirm_text} | q: cancel"
  end

  # ===========================================================================
  # Private - Theme-aware Style Resolution
  # ===========================================================================

  defp get_effective_cursor_style(multi_select) do
    case {multi_select.cursor_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :emphasis))

      _ ->
        nil
    end
  end

  defp get_effective_focused_style(multi_select) do
    case {multi_select.focused_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :header))

      _ ->
        nil
    end
  end

  defp get_effective_selected_marker_style(multi_select) do
    case {multi_select.selected_marker_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :success))

      _ ->
        nil
    end
  end

  defp get_effective_unselected_marker_style(multi_select) do
    case {multi_select.unselected_marker_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end

  defp get_effective_selected_item_style(multi_select) do
    case {multi_select.selected_item_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :success))

      _ ->
        nil
    end
  end

  defp get_effective_help_style(multi_select) do
    case {multi_select.help_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end

  defp get_effective_filter_style(multi_select) do
    case {multi_select.filter_style, multi_select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style() |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
