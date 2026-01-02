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
  - `Escape` / `q` - Cancel selection
  - `Home` / `g` - Jump to first item
  - `End` / `G` - Jump to last item

  ## Theme Integration

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default),
  the select automatically uses theme colors:

  - Cursor: theme `:emphasis` color
  - Selected item: theme `:header` color

  Explicit styles override theme colors. Use `use_theme(select, false)` to disable.
  """

  defstruct items: [],
            selected_index: 0,
            cursor: "> ",
            cursor_style: nil,
            selected_style: nil,
            item_style: nil,
            use_theme: true

  @type item :: String.t() | {String.t(), term()}

  @type t :: %__MODULE__{
          items: [item()],
          selected_index: non_neg_integer(),
          cursor: String.t(),
          cursor_style: Esc.Style.t() | nil,
          selected_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          use_theme: boolean()
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

    select.items
    |> Enum.with_index()
    |> Enum.map(fn {item, idx} ->
      display_text = get_display_text(item)
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

    # Read input using OTP 28 raw mode
    case read_key() do
      :up ->
        move_and_redraw(select, line_count, &move_up/1)

      :down ->
        move_and_redraw(select, line_count, &move_down/1)

      :home ->
        move_and_redraw(select, line_count, &move_home/1)

      :end_key ->
        move_and_redraw(select, line_count, &move_end/1)

      :enter ->
        IO.write("\r\n")
        {:ok, get_return_value(select)}

      :cancel ->
        clear_lines(line_count)
        :cancelled

      _ ->
        move_and_redraw(select, line_count, & &1)
    end
  end

  defp move_and_redraw(select, line_count, move_fn) do
    clear_lines(line_count)
    loop(move_fn.(select))
  end

  defp move_up(%__MODULE__{} = select) do
    count = length(select.items)
    new_index = if select.selected_index == 0, do: count - 1, else: select.selected_index - 1
    %{select | selected_index: new_index}
  end

  defp move_down(%__MODULE__{} = select) do
    count = length(select.items)
    new_index = if select.selected_index == count - 1, do: 0, else: select.selected_index + 1
    %{select | selected_index: new_index}
  end

  defp move_home(%__MODULE__{} = select) do
    %{select | selected_index: 0}
  end

  defp move_end(%__MODULE__{} = select) do
    %{select | selected_index: length(select.items) - 1}
  end

  # Key reading using OTP 28 raw mode with IO.getn
  defp read_key do
    case read_char() do
      "\e" -> read_escape_sequence()
      "\r" -> :enter
      "\n" -> :enter
      " " -> :enter
      "j" -> :down
      "k" -> :up
      "g" -> :home
      "G" -> :end_key
      "q" -> :cancel
      <<3>> -> :cancel  # Ctrl+C
      :eof -> :cancel
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

  # Helper functions
  defp get_display_text({text, _value}) when is_binary(text), do: text
  defp get_display_text(text) when is_binary(text), do: text

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
end
