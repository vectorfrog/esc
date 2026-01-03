defmodule Esc.Select do
  @moduledoc """
  Interactive selection list for terminal applications.

  Select provides a navigable list where users can move a cursor with arrow keys
  and confirm their selection with Enter.

  ## Example

      alias Esc.Select

      case Select.new(["Option 1", "Option 2", "Option 3"]) |> Select.run() do
        {:ok, selected} -> IO.puts("You selected: \#{selected}")
        :cancelled -> IO.puts("Selection cancelled")
      end

  ## Items with Custom Return Values

  Items can be tuples of `{display_text, return_value}`:

      Select.new([
        {"Production", :prod},
        {"Development", :dev}
      ])
      |> Select.run()
      # Returns {:ok, :prod} or {:ok, :dev}

  ## Keyboard Controls

  - `Up` / `k` - Move cursor up
  - `Down` / `j` - Move cursor down
  - `Enter` / `Space` - Confirm selection
  - `Escape` / `q` - Cancel selection (or exit filter mode)
  - `Home` / `g` - Jump to first item
  - `End` / `G` - Jump to last item
  - `/` - Enter filter mode
  - `Ctrl+F` / `]` - Next page
  - `Ctrl+B` / `[` - Previous page

  ## Filtering

  Press `/` to enter filter mode and type to filter items:

      # Filter narrows visible items as you type
      Select.new(["apple", "apricot", "banana", "cherry"])
      |> Select.run()
      # Type "ap" to show only "apple" and "apricot"

  Supports glob-style wildcards with `*`:

      # "*.md" matches "readme.md", "CHANGELOG.md"
      # "test*" matches "testing", "test_helper"
      # "*api*" matches "api_client", "rest_api", "api"

  Escape exits filter mode. Press Escape again to clear the filter.

  ## Theme Integration

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default),
  the select automatically uses theme colors:

  - Cursor: theme `:emphasis` color
  - Selected item: theme `:header` color

  Explicit styles override theme colors. Use `use_theme(select, false)` to disable.
  """

  @default_page_size 100

  defstruct items: [],
            selected_index: 0,
            cursor: "> ",
            cursor_style: nil,
            selected_style: nil,
            item_style: nil,
            use_theme: true,
            filter_mode: false,
            filter_text: "",
            filter_style: nil,
            page_size: @default_page_size,
            current_page: 0

  @type item :: String.t() | {String.t(), term()}

  @type t :: %__MODULE__{
          items: [item()],
          selected_index: non_neg_integer(),
          cursor: String.t(),
          cursor_style: Esc.Style.t() | nil,
          selected_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          use_theme: boolean(),
          filter_mode: boolean(),
          filter_text: String.t(),
          filter_style: Esc.Style.t() | nil,
          page_size: non_neg_integer() | nil,
          current_page: non_neg_integer()
        }

  @doc """
  Creates a new select with the given items.

  Items can be strings or `{display_text, return_value}` tuples.
  """
  @spec new([item()]) :: t()
  def new(items \\ []) when is_list(items) do
    %__MODULE__{items: items}
  end

  @doc """
  Adds an item to the select list.
  """
  @spec item(t(), item()) :: t()
  def item(%__MODULE__{} = select, item) do
    %{select | items: select.items ++ [item]}
  end

  @doc """
  Sets the cursor string shown next to the selected item.

  Default is `"> "`.
  """
  @spec cursor(t(), String.t()) :: t()
  def cursor(%__MODULE__{} = select, cursor) when is_binary(cursor) do
    %{select | cursor: cursor}
  end

  @doc """
  Sets the style for the cursor.
  """
  @spec cursor_style(t(), Esc.Style.t()) :: t()
  def cursor_style(%__MODULE__{} = select, style) do
    %{select | cursor_style: style}
  end

  @doc """
  Sets the style for the currently highlighted item text.
  """
  @spec selected_style(t(), Esc.Style.t()) :: t()
  def selected_style(%__MODULE__{} = select, style) do
    %{select | selected_style: style}
  end

  @doc """
  Sets the style for non-selected items.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = select, style) do
    %{select | item_style: style}
  end

  @doc """
  Enables or disables automatic theme colors.

  When enabled (default), the select uses theme colors for:
  - Cursor (`:emphasis` color)
  - Selected item (`:header` color)

  Explicit styles override theme colors.
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = select, enabled) when is_boolean(enabled) do
    %{select | use_theme: enabled}
  end

  @doc """
  Sets the style for the filter input line.
  """
  @spec filter_style(t(), Esc.Style.t()) :: t()
  def filter_style(%__MODULE__{} = select, style) do
    %{select | filter_style: style}
  end

  @doc """
  Sets the number of items displayed per page.

  Default is 100 items per page. Set to 0 or nil to disable pagination
  and show all items.

  ## Examples

      # Custom page size
      Select.new(items) |> Select.page_size(25)

      # Disable pagination
      Select.new(items) |> Select.page_size(0)
  """
  @spec page_size(t(), non_neg_integer() | nil) :: t()
  def page_size(%__MODULE__{} = select, size) when is_nil(size) or size >= 0 do
    %{select | page_size: size}
  end

  @doc """
  Renders the select list at its current state (non-interactive).

  This is useful for previewing the select or for testing.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{items: []}), do: ""

  def render(%__MODULE__{} = select) do
    cursor_width = String.length(select.cursor)
    blank_cursor = String.duplicate(" ", cursor_width)

    cursor_style = get_effective_cursor_style(select)
    selected_style = get_effective_selected_style(select)
    filter_style = get_effective_filter_style(select)

    # Get filtered items then paginate
    filtered_indices = Esc.Filter.matching_indices(select.items, select.filter_text)
    page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, select.current_page)
    total_pages = Esc.Filter.total_pages(select.items, select.filter_text, select.page_size)

    items_output =
      page_indices
      |> Enum.map(fn idx ->
        item = Enum.at(select.items, idx)
        display_text = Esc.Filter.get_display_text(item)
        is_selected = idx == select.selected_index

        if is_selected do
          styled_cursor = apply_style(select.cursor, cursor_style)
          styled_text = apply_style(display_text, selected_style)
          styled_cursor <> styled_text
        else
          styled_text = apply_style(display_text, select.item_style)
          blank_cursor <> styled_text
        end
      end)
      |> Enum.join("\n")

    # Build header line with filter and/or pagination
    header_parts = []

    header_parts =
      if select.filter_mode or select.filter_text != "" do
        filter_line = Esc.Filter.render_filter_input(
          select.filter_text,
          select.filter_mode,
          prompt_style: filter_style,
          match_count: {length(filtered_indices), length(select.items)},
          count_style: filter_style
        )
        header_parts ++ [filter_line]
      else
        header_parts
      end

    header_parts =
      if total_pages > 1 do
        pagination = Esc.Filter.render_pagination(select.current_page, total_pages, style: filter_style)
        header_parts ++ [pagination]
      else
        header_parts
      end

    case header_parts do
      [] -> items_output
      parts -> Enum.join(parts, " ") <> "\n\n" <> items_output
    end
  end

  @doc """
  Runs the interactive selection loop.

  Returns `{:ok, selected_value}` when the user confirms a selection,
  or `:cancelled` if the user presses Escape or q.

  For items defined as `{display_text, return_value}` tuples,
  the return_value is returned. For string items, the string itself is returned.
  """
  @spec run(t()) :: {:ok, term()} | :cancelled
  def run(%__MODULE__{items: []}), do: :cancelled

  def run(%__MODULE__{} = select) do
    # OTP 28+ raw terminal mode
    # Enter raw mode - reads characters immediately without buffering
    :shell.start_interactive({:noshell, :raw})

    # Hide cursor
    IO.write(hide_cursor())

    try do
      loop(select)
    after
      # Restore terminal state
      IO.write(show_cursor())
      :shell.start_interactive({:noshell, :cooked})
    end
  end

  # Main interaction loop
  defp loop(select) do
    # Render current state
    output = render(select)
    line_count = length(String.split(output, "\n"))

    # In raw mode, \n doesn't return to column 0, so use \r\n
    IO.write(String.replace(output, "\n", "\r\n"))

    # Read input - behavior depends on filter mode
    if select.filter_mode do
      handle_filter_mode_input(select, line_count)
    else
      handle_normal_mode_input(select, line_count)
    end
  end

  defp handle_normal_mode_input(select, line_count) do
    case read_key() do
      :up ->
        move_and_redraw(select, line_count, &move_up/1)

      :down ->
        move_and_redraw(select, line_count, &move_down/1)

      :home ->
        move_and_redraw(select, line_count, &move_home/1)

      :end_key ->
        move_and_redraw(select, line_count, &move_end/1)

      :page_forward ->
        move_and_redraw(select, line_count, &next_page/1)

      :page_backward ->
        move_and_redraw(select, line_count, &prev_page/1)

      :enter ->
        # Make sure cursor is on a valid filtered item
        page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, select.current_page)
        if select.selected_index in page_indices do
          IO.write("\r\n")
          {:ok, get_return_value(select)}
        else
          move_and_redraw(select, line_count, & &1)
        end

      :filter ->
        move_and_redraw(select, line_count, &enter_filter_mode/1)

      :cancel ->
        # If filter is active, first escape clears filter
        if select.filter_text != "" do
          move_and_redraw(select, line_count, &clear_filter/1)
        else
          clear_lines(line_count)
          :cancelled
        end

      _ ->
        move_and_redraw(select, line_count, & &1)
    end
  end

  defp handle_filter_mode_input(select, line_count) do
    case read_filter_key() do
      :escape ->
        # Exit filter mode; if filter empty and was empty, cancel
        if select.filter_text == "" do
          clear_lines(line_count)
          :cancelled
        else
          move_and_redraw(select, line_count, &exit_filter_mode/1)
        end

      :enter ->
        # Exit filter mode and confirm filter
        move_and_redraw(select, line_count, &exit_filter_mode/1)

      :backspace ->
        move_and_redraw(select, line_count, &delete_filter_char/1)

      :clear_line ->
        move_and_redraw(select, line_count, fn s -> %{s | filter_text: ""} end)

      {:char, char} ->
        move_and_redraw(select, line_count, &add_filter_char(&1, char))

      _ ->
        move_and_redraw(select, line_count, & &1)
    end
  end

  defp enter_filter_mode(select) do
    %{select | filter_mode: true}
  end

  defp exit_filter_mode(select) do
    # Ensure cursor is on a valid filtered item
    select = %{select | filter_mode: false}
    ensure_valid_cursor(select)
  end

  defp clear_filter(select) do
    %{select | filter_text: "", selected_index: 0, current_page: 0}
  end

  defp add_filter_char(select, char) do
    new_filter = select.filter_text <> char
    select = %{select | filter_text: new_filter, current_page: 0}
    ensure_valid_cursor(select)
  end

  defp delete_filter_char(%{filter_text: ""} = select), do: select
  defp delete_filter_char(select) do
    new_filter = String.slice(select.filter_text, 0..-2//1)
    %{select | filter_text: new_filter}
  end

  defp ensure_valid_cursor(select) do
    filtered_indices = Esc.Filter.matching_indices(select.items, select.filter_text)

    if select.selected_index in filtered_indices do
      select
    else
      # Move to first filtered item
      case filtered_indices do
        [first | _] -> %{select | selected_index: first}
        [] -> select
      end
    end
  end

  defp move_and_redraw(select, line_count, move_fn) do
    clear_lines(line_count)
    loop(move_fn.(select))
  end

  defp move_up(%__MODULE__{} = select) do
    page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, select.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == select.selected_index)) || 0

    if current_pos == 0 do
      # At top of page - go to previous page or wrap to last page
      total_pages = Esc.Filter.total_pages(select.items, select.filter_text, select.page_size)
      new_page = if select.current_page == 0, do: total_pages - 1, else: select.current_page - 1
      new_page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, new_page)
      new_index = List.last(new_page_indices) || select.selected_index
      %{select | selected_index: new_index, current_page: new_page}
    else
      new_index = Enum.at(page_indices, current_pos - 1) || select.selected_index
      %{select | selected_index: new_index}
    end
  end

  defp move_down(%__MODULE__{} = select) do
    page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, select.current_page)
    current_pos = Enum.find_index(page_indices, &(&1 == select.selected_index)) || 0

    if current_pos == length(page_indices) - 1 do
      # At bottom of page - go to next page or wrap to first page
      total_pages = Esc.Filter.total_pages(select.items, select.filter_text, select.page_size)
      new_page = if select.current_page == total_pages - 1, do: 0, else: select.current_page + 1
      new_page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, new_page)
      new_index = List.first(new_page_indices) || select.selected_index
      %{select | selected_index: new_index, current_page: new_page}
    else
      new_index = Enum.at(page_indices, current_pos + 1) || select.selected_index
      %{select | selected_index: new_index}
    end
  end

  defp move_home(%__MODULE__{} = select) do
    # Jump to absolute first item on first page
    page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, 0)
    new_index = List.first(page_indices) || 0
    %{select | selected_index: new_index, current_page: 0}
  end

  defp move_end(%__MODULE__{} = select) do
    # Jump to absolute last item across all pages
    total_pages = Esc.Filter.total_pages(select.items, select.filter_text, select.page_size)
    last_page = total_pages - 1
    page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, last_page)
    new_index = List.last(page_indices) || length(select.items) - 1
    %{select | selected_index: new_index, current_page: last_page}
  end

  defp next_page(%__MODULE__{} = select) do
    total_pages = Esc.Filter.total_pages(select.items, select.filter_text, select.page_size)
    if select.current_page < total_pages - 1 do
      new_page = select.current_page + 1
      page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, new_page)
      new_index = List.first(page_indices) || select.selected_index
      %{select | current_page: new_page, selected_index: new_index}
    else
      select
    end
  end

  defp prev_page(%__MODULE__{} = select) do
    if select.current_page > 0 do
      new_page = select.current_page - 1
      page_indices = Esc.Filter.page_indices(select.items, select.filter_text, select.page_size, new_page)
      new_index = List.first(page_indices) || select.selected_index
      %{select | current_page: new_page, selected_index: new_index}
    else
      select
    end
  end

  # Key reading using OTP 28 raw mode with IO.getn
  defp read_key do
    case read_char() do
      "\e" -> read_escape_sequence()
      "\r" -> :enter
      "\n" -> :enter
      " " -> :enter
      "/" -> :filter
      "j" -> :down
      "k" -> :up
      "g" -> :home
      "G" -> :end_key
      "]" -> :page_forward
      "[" -> :page_backward
      <<6>> -> :page_forward   # Ctrl+F
      <<2>> -> :page_backward  # Ctrl+B
      "q" -> :cancel
      <<3>> -> :cancel  # Ctrl+C
      :eof -> :cancel
      _ -> :unknown
    end
  end

  # Key reading in filter mode - captures printable characters
  defp read_filter_key do
    case read_char() do
      "\e" -> :escape
      "\r" -> :enter
      "\n" -> :enter
      <<127>> -> :backspace  # DEL
      <<8>> -> :backspace    # BS
      <<21>> -> :clear_line  # Ctrl+U
      <<3>> -> :escape       # Ctrl+C
      :eof -> :escape
      char when is_binary(char) ->
        # Accept printable characters
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
            # Handle sequences like \e[1~ (Home)
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
        # Bare escape = cancel
        :cancel
    end
  end

  # ANSI escape sequences
  defp hide_cursor, do: "\e[?25l"
  defp show_cursor, do: "\e[?25h"

  defp clear_lines(count) when count > 1 do
    # Cursor is on last line, move to column 0, move up (count-1) lines, clear to end of screen
    IO.write("\r\e[#{count - 1}A\e[J")
  end

  defp clear_lines(_count) do
    # Single line - just clear current line
    IO.write("\r\e[J")
  end

  defp get_return_value(%__MODULE__{items: items, selected_index: idx}) do
    case Enum.at(items, idx) do
      {_text, value} -> value
      text -> text
    end
  end

  defp apply_style(text, nil), do: text
  defp apply_style(text, style), do: Esc.render(style, text)

  # Theme-aware style resolution
  defp get_effective_cursor_style(select) do
    case {select.cursor_style, select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :emphasis))

      _ ->
        nil
    end
  end

  defp get_effective_selected_style(select) do
    case {select.selected_style, select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :header))

      _ ->
        nil
    end
  end

  defp get_effective_filter_style(select) do
    case {select.filter_style, select.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
