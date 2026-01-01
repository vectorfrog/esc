defmodule Esc do
  @moduledoc """
  Declarative terminal styling for Elixir.

  Esc provides an expressive API for styling terminal output with colors,
  borders, padding, margins, and text alignment.

  ## Example

      import Esc

      style()
      |> foreground(:red)
      |> bold()
      |> padding(1, 2)
      |> border(:rounded)
      |> render("Hello, World!")

  ## Colors

  Esc supports multiple color formats:

  - Named colors: `:red`, `:green`, `:blue`, `:cyan`, `:magenta`, `:yellow`, `:white`, `:black`
  - Bright variants: `:bright_red`, `:bright_green`, etc.
  - ANSI 256 palette: integers `0..255`
  - True color: `{r, g, b}` tuples or hex strings like `"#ff5733"`

  ## Borders

  Available border styles: `:normal`, `:rounded`, `:thick`, `:double`, `:hidden`
  """

  alias Esc.{Style, Color, Border, Theme}

  @type style :: Style.t()

  # Style constructor

  @doc """
  Creates a new empty style.
  """
  @spec style() :: style()
  def style, do: %Style{}

  # Colors

  @doc """
  Sets the foreground (text) color.
  """
  @spec foreground(style(), Style.color()) :: style()
  def foreground(%Style{} = s, color), do: %{s | foreground: color}

  @doc """
  Sets the background color.
  """
  @spec background(style(), Style.color()) :: style()
  def background(%Style{} = s, color), do: %{s | background: color}

  # Text formatting

  @doc "Enables bold text."
  @spec bold(style()) :: style()
  def bold(%Style{} = s), do: %{s | bold: true}

  @doc "Enables italic text."
  @spec italic(style()) :: style()
  def italic(%Style{} = s), do: %{s | italic: true}

  @doc "Enables underlined text."
  @spec underline(style()) :: style()
  def underline(%Style{} = s), do: %{s | underline: true}

  @doc "Enables strikethrough text."
  @spec strikethrough(style()) :: style()
  def strikethrough(%Style{} = s), do: %{s | strikethrough: true}

  @doc "Enables faint/dim text."
  @spec faint(style()) :: style()
  def faint(%Style{} = s), do: %{s | faint: true}

  @doc "Enables blinking text."
  @spec blink(style()) :: style()
  def blink(%Style{} = s), do: %{s | blink: true}

  @doc "Enables reverse video (swap foreground/background)."
  @spec reverse(style()) :: style()
  def reverse(%Style{} = s), do: %{s | reverse: true}

  # Padding

  @doc """
  Sets padding on all sides.
  """
  @spec padding(style(), non_neg_integer()) :: style()
  def padding(%Style{} = s, all) when is_integer(all) and all >= 0 do
    %{s | padding_top: all, padding_right: all, padding_bottom: all, padding_left: all}
  end

  @doc """
  Sets vertical and horizontal padding.
  """
  @spec padding(style(), non_neg_integer(), non_neg_integer()) :: style()
  def padding(%Style{} = s, vertical, horizontal)
      when is_integer(vertical) and is_integer(horizontal) and vertical >= 0 and horizontal >= 0 do
    %{s | padding_top: vertical, padding_right: horizontal, padding_bottom: vertical, padding_left: horizontal}
  end

  @doc """
  Sets padding for each side individually.
  """
  @spec padding(style(), non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()) :: style()
  def padding(%Style{} = s, top, right, bottom, left) do
    %{s | padding_top: top, padding_right: right, padding_bottom: bottom, padding_left: left}
  end

  # Margins

  @doc """
  Sets margin on all sides.
  """
  @spec margin(style(), non_neg_integer()) :: style()
  def margin(%Style{} = s, all) when is_integer(all) and all >= 0 do
    %{s | margin_top: all, margin_right: all, margin_bottom: all, margin_left: all}
  end

  @doc """
  Sets vertical and horizontal margin.
  """
  @spec margin(style(), non_neg_integer(), non_neg_integer()) :: style()
  def margin(%Style{} = s, vertical, horizontal)
      when is_integer(vertical) and is_integer(horizontal) and vertical >= 0 and horizontal >= 0 do
    %{s | margin_top: vertical, margin_right: horizontal, margin_bottom: vertical, margin_left: horizontal}
  end

  @doc """
  Sets margin for each side individually.
  """
  @spec margin(style(), non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()) :: style()
  def margin(%Style{} = s, top, right, bottom, left) do
    %{s | margin_top: top, margin_right: right, margin_bottom: bottom, margin_left: left}
  end

  # Border

  @doc """
  Sets the border style.

  Available styles: `:normal`, `:rounded`, `:thick`, `:double`, `:hidden`
  """
  @spec border(style(), atom()) :: style()
  def border(%Style{} = s, style) when is_atom(style), do: %{s | border: style}

  @doc """
  Sets the border foreground color.
  """
  @spec border_foreground(style(), Style.color()) :: style()
  def border_foreground(%Style{} = s, color), do: %{s | border_foreground: color}

  @doc """
  Sets the border background color.
  """
  @spec border_background(style(), Style.color()) :: style()
  def border_background(%Style{} = s, color), do: %{s | border_background: color}

  @doc """
  Enables or disables the top border.
  """
  @spec border_top(style(), boolean()) :: style()
  def border_top(%Style{} = s, enabled), do: %{s | border_top: enabled}

  @doc """
  Enables or disables the right border.
  """
  @spec border_right(style(), boolean()) :: style()
  def border_right(%Style{} = s, enabled), do: %{s | border_right: enabled}

  @doc """
  Enables or disables the bottom border.
  """
  @spec border_bottom(style(), boolean()) :: style()
  def border_bottom(%Style{} = s, enabled), do: %{s | border_bottom: enabled}

  @doc """
  Enables or disables the left border.
  """
  @spec border_left(style(), boolean()) :: style()
  def border_left(%Style{} = s, enabled), do: %{s | border_left: enabled}

  @doc """
  Sets a custom border with user-defined characters.

  ## Options

  - `:top` - Top edge character
  - `:bottom` - Bottom edge character
  - `:left` - Left edge character
  - `:right` - Right edge character
  - `:top_left` - Top-left corner character
  - `:top_right` - Top-right corner character
  - `:bottom_left` - Bottom-left corner character
  - `:bottom_right` - Bottom-right corner character

  ## Examples

      style()
      |> custom_border(
        top: "=",
        bottom: "=",
        left: "|",
        right: "|",
        top_left: "+",
        top_right: "+",
        bottom_left: "+",
        bottom_right: "+"
      )
      |> render("Custom box")
  """
  @spec custom_border(style(), keyword()) :: style()
  def custom_border(%Style{} = s, opts) do
    %{s | border: Border.custom(opts)}
  end

  # Dimensions

  @doc """
  Sets a fixed width for the output.
  """
  @spec width(style(), non_neg_integer()) :: style()
  def width(%Style{} = s, w) when is_integer(w) and w >= 0, do: %{s | width: w}

  @doc """
  Sets a fixed height for the output.
  """
  @spec height(style(), non_neg_integer()) :: style()
  def height(%Style{} = s, h) when is_integer(h) and h >= 0, do: %{s | height: h}

  # Alignment

  @doc """
  Sets horizontal text alignment.
  """
  @spec align(style(), :left | :center | :right) :: style()
  def align(%Style{} = s, alignment) when alignment in [:left, :center, :right] do
    %{s | align_horizontal: alignment}
  end

  @doc """
  Sets vertical text alignment.
  """
  @spec vertical_align(style(), :top | :middle | :bottom) :: style()
  def vertical_align(%Style{} = s, alignment) when alignment in [:top, :middle, :bottom] do
    %{s | align_vertical: alignment}
  end

  # Style management

  @doc """
  Creates a copy of a style.

  Since Elixir data is immutable, this is technically just returning
  the same struct, but it's provided for API parity with Lipgloss.
  """
  @spec copy(style()) :: style()
  def copy(%Style{} = s), do: s

  @doc """
  Inherits unset properties from another style.

  Only properties that are at their default values in the current style
  will be inherited from the base style.

  ## Examples

      base = style() |> foreground(:red) |> bold()
      derived = style() |> foreground(:blue) |> inherit(base)
      # derived has blue foreground (not inherited) and bold (inherited)
  """
  @spec inherit(style(), style()) :: style()
  def inherit(%Style{} = s, %Style{} = base) do
    default = %Style{}

    %Style{
      foreground: if(s.foreground == default.foreground, do: base.foreground, else: s.foreground),
      background: if(s.background == default.background, do: base.background, else: s.background),
      bold: if(s.bold == default.bold, do: base.bold, else: s.bold),
      italic: if(s.italic == default.italic, do: base.italic, else: s.italic),
      underline: if(s.underline == default.underline, do: base.underline, else: s.underline),
      strikethrough: if(s.strikethrough == default.strikethrough, do: base.strikethrough, else: s.strikethrough),
      faint: if(s.faint == default.faint, do: base.faint, else: s.faint),
      blink: if(s.blink == default.blink, do: base.blink, else: s.blink),
      reverse: if(s.reverse == default.reverse, do: base.reverse, else: s.reverse),
      padding_top: if(s.padding_top == default.padding_top, do: base.padding_top, else: s.padding_top),
      padding_right: if(s.padding_right == default.padding_right, do: base.padding_right, else: s.padding_right),
      padding_bottom: if(s.padding_bottom == default.padding_bottom, do: base.padding_bottom, else: s.padding_bottom),
      padding_left: if(s.padding_left == default.padding_left, do: base.padding_left, else: s.padding_left),
      margin_top: if(s.margin_top == default.margin_top, do: base.margin_top, else: s.margin_top),
      margin_right: if(s.margin_right == default.margin_right, do: base.margin_right, else: s.margin_right),
      margin_bottom: if(s.margin_bottom == default.margin_bottom, do: base.margin_bottom, else: s.margin_bottom),
      margin_left: if(s.margin_left == default.margin_left, do: base.margin_left, else: s.margin_left),
      border: if(s.border == default.border, do: base.border, else: s.border),
      border_top: if(s.border_top == default.border_top, do: base.border_top, else: s.border_top),
      border_right: if(s.border_right == default.border_right, do: base.border_right, else: s.border_right),
      border_bottom: if(s.border_bottom == default.border_bottom, do: base.border_bottom, else: s.border_bottom),
      border_left: if(s.border_left == default.border_left, do: base.border_left, else: s.border_left),
      border_foreground: if(s.border_foreground == default.border_foreground, do: base.border_foreground, else: s.border_foreground),
      border_background: if(s.border_background == default.border_background, do: base.border_background, else: s.border_background),
      width: if(s.width == default.width, do: base.width, else: s.width),
      height: if(s.height == default.height, do: base.height, else: s.height),
      align_horizontal: if(s.align_horizontal == default.align_horizontal, do: base.align_horizontal, else: s.align_horizontal),
      align_vertical: if(s.align_vertical == default.align_vertical, do: base.align_vertical, else: s.align_vertical),
      tab_width: if(s.tab_width == default.tab_width, do: base.tab_width, else: s.tab_width),
      inline: if(s.inline == default.inline, do: base.inline, else: s.inline),
      max_width: if(s.max_width == default.max_width, do: base.max_width, else: s.max_width),
      max_height: if(s.max_height == default.max_height, do: base.max_height, else: s.max_height),
      no_color: if(s.no_color == default.no_color, do: base.no_color, else: s.no_color),
      renderer: if(s.renderer == default.renderer, do: base.renderer, else: s.renderer)
    }
  end

  # Unset functions

  @doc "Removes the foreground color."
  @spec unset_foreground(style()) :: style()
  def unset_foreground(%Style{} = s), do: %{s | foreground: nil}

  @doc "Removes the background color."
  @spec unset_background(style()) :: style()
  def unset_background(%Style{} = s), do: %{s | background: nil}

  @doc "Disables bold."
  @spec unset_bold(style()) :: style()
  def unset_bold(%Style{} = s), do: %{s | bold: false}

  @doc "Disables italic."
  @spec unset_italic(style()) :: style()
  def unset_italic(%Style{} = s), do: %{s | italic: false}

  @doc "Disables underline."
  @spec unset_underline(style()) :: style()
  def unset_underline(%Style{} = s), do: %{s | underline: false}

  @doc "Disables strikethrough."
  @spec unset_strikethrough(style()) :: style()
  def unset_strikethrough(%Style{} = s), do: %{s | strikethrough: false}

  @doc "Disables faint."
  @spec unset_faint(style()) :: style()
  def unset_faint(%Style{} = s), do: %{s | faint: false}

  @doc "Disables blink."
  @spec unset_blink(style()) :: style()
  def unset_blink(%Style{} = s), do: %{s | blink: false}

  @doc "Disables reverse."
  @spec unset_reverse(style()) :: style()
  def unset_reverse(%Style{} = s), do: %{s | reverse: false}

  @doc "Removes all padding."
  @spec unset_padding(style()) :: style()
  def unset_padding(%Style{} = s) do
    %{s | padding_top: 0, padding_right: 0, padding_bottom: 0, padding_left: 0}
  end

  @doc "Removes all margin."
  @spec unset_margin(style()) :: style()
  def unset_margin(%Style{} = s) do
    %{s | margin_top: 0, margin_right: 0, margin_bottom: 0, margin_left: 0}
  end

  @doc "Removes the border."
  @spec unset_border(style()) :: style()
  def unset_border(%Style{} = s), do: %{s | border: nil}

  @doc "Removes the width constraint."
  @spec unset_width(style()) :: style()
  def unset_width(%Style{} = s), do: %{s | width: nil}

  @doc "Removes the height constraint."
  @spec unset_height(style()) :: style()
  def unset_height(%Style{} = s), do: %{s | height: nil}

  # Rendering system

  @doc """
  Enables or disables inline mode.

  In inline mode:
  - Newlines are stripped from content
  - Width and height constraints are ignored
  """
  @spec inline(style(), boolean()) :: style()
  def inline(%Style{} = s, enabled), do: %{s | inline: enabled}

  @doc """
  Sets the maximum width for rendered content.

  Content exceeding this width will be truncated.
  """
  @spec max_width(style(), non_neg_integer()) :: style()
  def max_width(%Style{} = s, width) when is_integer(width) and width >= 0 do
    %{s | max_width: width}
  end

  @doc """
  Sets the maximum height for rendered content.

  Content exceeding this height will be truncated.
  """
  @spec max_height(style(), non_neg_integer()) :: style()
  def max_height(%Style{} = s, height) when is_integer(height) and height >= 0 do
    %{s | max_height: height}
  end

  @doc """
  Enables or disables color output.

  When disabled, all ANSI color codes are stripped from output.
  Layout (borders, padding) is preserved.
  """
  @spec no_color(style(), boolean()) :: style()
  def no_color(%Style{} = s, enabled), do: %{s | no_color: enabled}

  @doc """
  Sets a custom renderer function.

  The renderer receives the text and style, and returns the rendered output.

  ## Examples

      upcase_renderer = fn text, _style -> String.upcase(text) end

      style()
      |> renderer(upcase_renderer)
      |> render("hello")
      # "HELLO"
  """
  @spec renderer(style(), (String.t(), Style.t() -> String.t())) :: style()
  def renderer(%Style{} = s, render_fn) when is_function(render_fn, 2) do
    %{s | renderer: render_fn}
  end

  @doc """
  Detects if the terminal has a dark background.

  Returns `true` for dark backgrounds, `false` for light backgrounds.
  This is a best-effort detection and may not be accurate on all terminals.
  """
  @spec has_dark_background?() :: boolean()
  def has_dark_background? do
    # Check COLORFGBG environment variable (format: "fg;bg")
    case System.get_env("COLORFGBG") do
      nil -> true  # Default to dark
      value ->
        case String.split(value, ";") do
          [_, bg | _] ->
            case Integer.parse(bg) do
              {n, _} when n in [0, 1, 2, 3, 4, 5, 6, 8] -> true   # Dark colors
              {n, _} when n in [7, 15] -> false  # Light colors
              _ -> true
            end
          _ -> true
        end
    end
  end

  @doc """
  Detects the color profile supported by the terminal.

  Returns one of:
  - `:no_color` - No color support (NO_COLOR env set or not a TTY)
  - `:ansi` - Basic 16 colors
  - `:ansi256` - 256 color palette
  - `:true_color` - 24-bit true color
  """
  @spec color_profile() :: :no_color | :ansi | :ansi256 | :true_color
  def color_profile do
    cond do
      Application.get_env(:esc, :force_color, false) -> detect_color_depth()
      System.get_env("NO_COLOR") != nil -> :no_color
      not io_tty?() -> :no_color
      true -> detect_color_depth()
    end
  end

  defp io_tty? do
    case :io.getopts(:standard_io) do
      opts when is_list(opts) ->
        Keyword.get(opts, :encoding, :latin1) != :latin1
      _ -> false
    end
  rescue
    _ -> false
  end

  defp detect_color_depth do
    colorterm = System.get_env("COLORTERM", "")
    term = System.get_env("TERM", "")

    cond do
      colorterm in ["truecolor", "24bit"] -> :true_color
      String.contains?(term, "256color") -> :ansi256
      String.contains?(term, "color") -> :ansi
      term != "" -> :ansi
      true -> :no_color
    end
  end

  # Themes

  @doc """
  Sets the global theme.

  Themes provide a consistent color palette including 16 ANSI colors,
  background/foreground colors, and semantic colors for common UI purposes.

  ## Examples

      Esc.set_theme(:nord)
      Esc.set_theme(:dracula)

  ## Available Themes

  #{Enum.map_join(Theme.Palette.list(), ", ", &inspect/1)}
  """
  @spec set_theme(atom() | Theme.t()) :: :ok | {:error, :unknown_theme}
  def set_theme(theme), do: Theme.Store.set(theme)

  @doc """
  Gets the current global theme, or nil if not set.

  ## Examples

      Esc.set_theme(:nord)
      Esc.get_theme()
      #=> %Esc.Theme{name: :nord, ...}
  """
  @spec get_theme() :: Theme.t() | nil
  def get_theme, do: Theme.Store.get()

  @doc """
  Clears the current global theme.

  After clearing, `get_theme/0` will return nil (or fall back to Application config).
  """
  @spec clear_theme() :: :ok
  def clear_theme, do: Theme.Store.clear()

  @doc """
  Lists all available built-in theme names.

  ## Examples

      Esc.themes()
      #=> [:dracula, :nord, :gruvbox, :one, :solarized, :monokai,
      #    :material, :github, :aura, :dolphin, :chalk, :cobalt]
  """
  @spec themes() :: [atom()]
  def themes, do: Theme.Palette.list()

  @doc """
  Gets a color from the current theme by name.

  Returns nil if no theme is set or the color is not defined.

  ## Semantic Colors

  - `:header` - Headers, titles (defaults to cyan)
  - `:emphasis` - Important text (defaults to blue)
  - `:warning` - Warning messages (defaults to yellow)
  - `:error` - Error messages (defaults to red)
  - `:success` - Success messages (defaults to green)
  - `:muted` - Subdued text, borders (defaults to gray)

  ## ANSI Colors

  `:ansi_0` through `:ansi_15`, `:background`, `:foreground`

  ## Examples

      Esc.set_theme(:nord)
      Esc.theme_color(:error)
      #=> {191, 97, 106}
  """
  @spec theme_color(atom()) :: Style.color() | nil
  def theme_color(name) do
    case get_theme() do
      nil -> nil
      theme -> Theme.color(theme, name)
    end
  end

  @doc """
  Sets foreground color from the current theme.

  If no theme is set or the color is not defined, the style is unchanged.

  ## Examples

      style() |> theme_foreground(:error) |> render("Error!")
  """
  @spec theme_foreground(style(), atom()) :: style()
  def theme_foreground(%Style{} = s, color_name) do
    case theme_color(color_name) do
      nil -> s
      color -> foreground(s, color)
    end
  end

  @doc """
  Sets background color from the current theme.

  If no theme is set or the color is not defined, the style is unchanged.

  ## Examples

      style() |> theme_background(:success) |> render("Success!")
  """
  @spec theme_background(style(), atom()) :: style()
  def theme_background(%Style{} = s, color_name) do
    case theme_color(color_name) do
      nil -> s
      color -> background(s, color)
    end
  end

  @doc """
  Sets border foreground color from the current theme.

  If no theme is set or the color is not defined, the style is unchanged.

  ## Examples

      style() |> border(:rounded) |> theme_border_foreground(:muted) |> render("Box")
  """
  @spec theme_border_foreground(style(), atom()) :: style()
  def theme_border_foreground(%Style{} = s, color_name) do
    case theme_color(color_name) do
      nil -> s
      color -> border_foreground(s, color)
    end
  end

  @doc """
  Sets border background color from the current theme.

  If no theme is set or the color is not defined, the style is unchanged.
  """
  @spec theme_border_background(style(), atom()) :: style()
  def theme_border_background(%Style{} = s, color_name) do
    case theme_color(color_name) do
      nil -> s
      color -> border_background(s, color)
    end
  end

  # Tab handling

  @doc """
  Sets the tab width for tab-to-space conversion.

  A value of 0 preserves tabs as-is. Default is 4.
  """
  @spec tab_width(style(), non_neg_integer()) :: style()
  def tab_width(%Style{} = s, width) when is_integer(width) and width >= 0 do
    %{s | tab_width: width}
  end

  # Text measurement

  @doc """
  Returns the visible width of text, ignoring ANSI escape codes.

  For multiline text, returns the width of the widest line.

  ## Examples

      iex> Esc.get_width("Hello")
      5

      iex> Esc.get_width("Short\\nMuch longer")
      11
  """
  @spec get_width(String.t()) :: non_neg_integer()
  def get_width(text) when is_binary(text) do
    text
    |> String.split("\n")
    |> Enum.map(&display_width/1)
    |> Enum.max(fn -> 0 end)
  end

  @doc """
  Returns the height (line count) of text.

  ## Examples

      iex> Esc.get_height("Single line")
      1

      iex> Esc.get_height("Line 1\\nLine 2\\nLine 3")
      3
  """
  @spec get_height(String.t()) :: non_neg_integer()
  def get_height(text) when is_binary(text) do
    text
    |> String.split("\n")
    |> length()
  end

  # Joining

  @doc """
  Joins multiple text blocks horizontally (side by side).

  ## Options

  The second argument specifies vertical alignment:
  - `:top` (default) - Align blocks to the top
  - `:middle` - Center blocks vertically
  - `:bottom` - Align blocks to the bottom

  ## Examples

      left = "A\\nB"
      right = "1\\n2"
      Esc.join_horizontal([left, right])
      # "A1\\nB2"
  """
  @spec join_horizontal([String.t()], :top | :middle | :bottom) :: String.t()
  def join_horizontal(blocks, align \\ :top) when is_list(blocks) do
    # Get max height
    max_height = blocks |> Enum.map(&get_height/1) |> Enum.max(fn -> 0 end)

    # Pad each block to max height with alignment
    padded_blocks =
      Enum.map(blocks, fn block ->
        lines = String.split(block, "\n")
        width = get_width(block)
        current_height = length(lines)
        pad_count = max_height - current_height

        padded_lines =
          case align do
            :top ->
              lines ++ List.duplicate(String.duplicate(" ", width), pad_count)

            :bottom ->
              List.duplicate(String.duplicate(" ", width), pad_count) ++ lines

            :middle ->
              top_pad = div(pad_count, 2)
              bottom_pad = pad_count - top_pad
              empty = String.duplicate(" ", width)
              List.duplicate(empty, top_pad) ++ lines ++ List.duplicate(empty, bottom_pad)
          end

        # Ensure all lines are same width
        Enum.map(padded_lines, fn line ->
          line_width = display_width(line)
          if line_width < width do
            line <> String.duplicate(" ", width - line_width)
          else
            line
          end
        end)
      end)

    # Combine lines horizontally
    0..(max_height - 1)
    |> Enum.map(fn i ->
      padded_blocks
      |> Enum.map(fn lines -> Enum.at(lines, i, "") end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  @doc """
  Joins multiple text blocks vertically (stacked).

  ## Options

  The second argument specifies horizontal alignment:
  - `:left` (default) - Align blocks to the left
  - `:center` - Center blocks horizontally
  - `:right` - Align blocks to the right

  ## Examples

      top = "AAA"
      bottom = "B"
      Esc.join_vertical([top, bottom], :center)
      # "AAA\\n B "
  """
  @spec join_vertical([String.t()], :left | :center | :right) :: String.t()
  def join_vertical(blocks, align \\ :left) when is_list(blocks) do
    # Get max width
    max_width = blocks |> Enum.map(&get_width/1) |> Enum.max(fn -> 0 end)

    # Pad each line to max width with alignment
    blocks
    |> Enum.flat_map(fn block ->
      String.split(block, "\n")
    end)
    |> Enum.map(fn line ->
      line_width = display_width(line)
      pad_count = max_width - line_width

      case align do
        :left ->
          line <> String.duplicate(" ", pad_count)

        :right ->
          String.duplicate(" ", pad_count) <> line

        :center ->
          left = div(pad_count, 2)
          right = pad_count - left
          String.duplicate(" ", left) <> line <> String.duplicate(" ", right)
      end
    end)
    |> Enum.join("\n")
  end

  # Placement

  @doc """
  Places text within a box of specified dimensions.

  ## Examples

      Esc.place(20, 5, :center, :middle, "X")
      # Returns a 20x5 box with "X" centered
  """
  @spec place(non_neg_integer(), non_neg_integer(), :left | :center | :right, :top | :middle | :bottom, String.t()) :: String.t()
  def place(width, height, h_align, v_align, text) do
    text
    |> then(&place_horizontal(width, h_align, &1))
    |> then(&place_vertical(height, v_align, &1))
  end

  @doc """
  Places text horizontally within a specified width.

  ## Examples

      Esc.place_horizontal(20, :center, "Hi")
      # "         Hi         "
  """
  @spec place_horizontal(non_neg_integer(), :left | :center | :right, String.t()) :: String.t()
  def place_horizontal(width, align, text) do
    lines = String.split(text, "\n")

    Enum.map(lines, fn line ->
      line_width = display_width(line)

      if line_width >= width do
        line
      else
        pad_count = width - line_width

        case align do
          :left ->
            line <> String.duplicate(" ", pad_count)

          :right ->
            String.duplicate(" ", pad_count) <> line

          :center ->
            left = div(pad_count, 2)
            right = pad_count - left
            String.duplicate(" ", left) <> line <> String.duplicate(" ", right)
        end
      end
    end)
    |> Enum.join("\n")
  end

  @doc """
  Places text vertically within a specified height.

  ## Examples

      Esc.place_vertical(5, :middle, "X")
      # Returns 5 lines with "X" on the middle line
  """
  @spec place_vertical(non_neg_integer(), :top | :middle | :bottom, String.t()) :: String.t()
  def place_vertical(height, align, text) do
    lines = String.split(text, "\n")
    current_height = length(lines)

    if current_height >= height do
      text
    else
      pad_count = height - current_height
      width = get_width(text)
      empty_line = String.duplicate(" ", width)

      padded =
        case align do
          :top ->
            lines ++ List.duplicate(empty_line, pad_count)

          :bottom ->
            List.duplicate(empty_line, pad_count) ++ lines

          :middle ->
            top = div(pad_count, 2)
            bottom = pad_count - top
            List.duplicate(empty_line, top) ++ lines ++ List.duplicate(empty_line, bottom)
        end

      Enum.join(padded, "\n")
    end
  end

  # Rendering

  @doc """
  Renders text with the given style applied.
  """
  @spec render(style(), String.t()) :: String.t()
  def render(%Style{renderer: renderer} = style, text) when is_binary(text) and is_function(renderer, 2) do
    renderer.(text, style)
  end

  def render(%Style{inline: true} = style, text) when is_binary(text) do
    # Inline mode: strip newlines and ignore dimensions
    text
    |> String.replace("\n", " ")
    |> apply_tabs(style)
    |> apply_text_styles(style)
    |> apply_max_dimensions(style)
    |> apply_no_color(style)
  end

  def render(%Style{} = style, text) when is_binary(text) do
    text
    |> apply_tabs(style)
    |> apply_padding(style)
    |> apply_dimensions(style)
    |> apply_border(style)
    |> apply_margin(style)
    |> apply_text_styles(style)
    |> apply_max_dimensions(style)
    |> apply_no_color(style)
  end

  defp apply_max_dimensions(text, %Style{max_width: nil, max_height: nil}), do: text

  defp apply_max_dimensions(text, %Style{} = s) do
    lines = String.split(text, "\n")

    # Apply max_height first
    lines =
      if s.max_height do
        Enum.take(lines, s.max_height)
      else
        lines
      end

    # Apply max_width to each line
    lines =
      if s.max_width do
        Enum.map(lines, fn line ->
          truncate_to_visible_width(line, s.max_width)
        end)
      else
        lines
      end

    Enum.join(lines, "\n")
  end

  defp truncate_to_visible_width(line, max_width) do
    # Need to handle ANSI codes - we can't just slice the string
    # We need to count visible characters and preserve codes
    {result, _visible_count, _in_code} =
      line
      |> String.graphemes()
      |> Enum.reduce({"", 0, false}, fn char, {acc, visible, in_code} ->
        cond do
          # Starting an escape sequence
          char == "\e" ->
            {acc <> char, visible, true}

          # Inside escape sequence
          in_code ->
            new_in_code = not (char == "m")
            {acc <> char, visible, new_in_code}

          # Regular character
          visible < max_width ->
            {acc <> char, visible + 1, false}

          # Exceeded max width
          true ->
            {acc, visible, false}
        end
      end)

    result
  end

  defp apply_no_color(text, %Style{no_color: false}), do: text

  defp apply_no_color(text, %Style{no_color: true}) do
    String.replace(text, ~r/\e\[[0-9;]*m/, "")
  end

  defp apply_tabs(text, %Style{tab_width: 0}), do: text
  defp apply_tabs(text, %Style{tab_width: width}) do
    String.replace(text, "\t", String.duplicate(" ", width))
  end

  defp apply_text_styles(text, %Style{} = s) do
    codes = build_style_codes(s)
    reset = "\e[0m"

    if codes == "" do
      text
    else
      text
      |> String.split("\n")
      |> Enum.map(fn line -> codes <> line <> reset end)
      |> Enum.join("\n")
    end
  end

  defp build_style_codes(%Style{} = s) do
    []
    |> add_if(s.bold, "\e[1m")
    |> add_if(s.faint, "\e[2m")
    |> add_if(s.italic, "\e[3m")
    |> add_if(s.underline, "\e[4m")
    |> add_if(s.blink, "\e[5m")
    |> add_if(s.reverse, "\e[7m")
    |> add_if(s.strikethrough, "\e[9m")
    |> add_color(s.foreground, &Color.foreground/1)
    |> add_color(s.background, &Color.background/1)
    |> Enum.join()
  end

  defp add_if(list, true, code), do: [code | list]
  defp add_if(list, false, _code), do: list

  defp add_color(list, nil, _fn), do: list
  defp add_color(list, color, color_fn), do: [color_fn.(color) | list]

  defp apply_padding(text, %Style{} = s) do
    lines = String.split(text, "\n")
    left_pad = String.duplicate(" ", s.padding_left)
    right_pad = String.duplicate(" ", s.padding_right)

    padded_lines = Enum.map(lines, fn line -> left_pad <> line <> right_pad end)

    top_lines = List.duplicate(left_pad <> right_pad, s.padding_top)
    bottom_lines = List.duplicate(left_pad <> right_pad, s.padding_bottom)

    (top_lines ++ padded_lines ++ bottom_lines)
    |> Enum.join("\n")
  end

  defp apply_border(text, %Style{border: nil}), do: text

  defp apply_border(text, %Style{} = s) do
    border = get_border(s.border)

    case border do
      nil ->
        text

      border ->
        # Check if any border is enabled
        if not s.border_top and not s.border_bottom and not s.border_left and not s.border_right do
          text
        else
          render_border(text, s, border)
        end
    end
  end

  defp get_border(%Border{} = border), do: border
  defp get_border(style) when is_atom(style), do: Border.get(style)

  defp render_border(text, %Style{} = s, border) do
    lines = String.split(text, "\n")
    max_width = lines |> Enum.map(&display_width/1) |> Enum.max(fn -> 0 end)

    border_codes = build_border_codes(s)
    reset = if border_codes == "", do: "", else: "\e[0m"

    # Build middle lines with optional left/right borders
    middle =
      Enum.map(lines, fn line ->
        padding = String.duplicate(" ", max_width - display_width(line))
        left_border = if s.border_left, do: border_codes <> border.left <> reset, else: ""
        right_border = if s.border_right, do: border_codes <> border.right <> reset, else: ""
        left_border <> line <> padding <> right_border
      end)

    # Build result with optional top/bottom borders
    result = middle

    result =
      if s.border_top do
        top_left = if s.border_left, do: border.top_left, else: ""
        top_right = if s.border_right, do: border.top_right, else: ""
        top = border_codes <> top_left <> String.duplicate(border.top, max_width) <> top_right <> reset
        [top | result]
      else
        result
      end

    result =
      if s.border_bottom do
        bottom_left = if s.border_left, do: border.bottom_left, else: ""
        bottom_right = if s.border_right, do: border.bottom_right, else: ""
        bottom = border_codes <> bottom_left <> String.duplicate(border.bottom, max_width) <> bottom_right <> reset
        result ++ [bottom]
      else
        result
      end

    Enum.join(result, "\n")
  end

  defp build_border_codes(%Style{} = s) do
    []
    |> add_color(s.border_foreground, &Color.foreground/1)
    |> add_color(s.border_background, &Color.background/1)
    |> Enum.join()
  end

  defp apply_margin(text, %Style{} = s) do
    lines = String.split(text, "\n")
    left_margin = String.duplicate(" ", s.margin_left)

    margined_lines = Enum.map(lines, fn line -> left_margin <> line end)

    top_lines = List.duplicate("", s.margin_top)
    bottom_lines = List.duplicate("", s.margin_bottom)

    (top_lines ++ margined_lines ++ bottom_lines)
    |> Enum.join("\n")
  end

  defp apply_dimensions(text, %Style{width: nil, height: nil}), do: text

  defp apply_dimensions(text, %Style{} = s) do
    lines = String.split(text, "\n")

    lines =
      if s.width do
        Enum.map(lines, fn line ->
          current_width = display_width(line)

          cond do
            current_width < s.width ->
              pad = String.duplicate(" ", s.width - current_width)

              case s.align_horizontal do
                :left -> line <> pad
                :right -> pad <> line
                :center ->
                  left = div(s.width - current_width, 2)
                  right = s.width - current_width - left
                  String.duplicate(" ", left) <> line <> String.duplicate(" ", right)
              end

            current_width > s.width ->
              truncate_to_width(line, s.width)

            true ->
              line
          end
        end)
      else
        lines
      end

    lines =
      if s.height do
        current_height = length(lines)

        cond do
          current_height < s.height ->
            empty_line = if s.width, do: String.duplicate(" ", s.width), else: ""
            padding_count = s.height - current_height

            case s.align_vertical do
              :top -> lines ++ List.duplicate(empty_line, padding_count)
              :bottom -> List.duplicate(empty_line, padding_count) ++ lines
              :middle ->
                top = div(padding_count, 2)
                bottom = padding_count - top
                List.duplicate(empty_line, top) ++ lines ++ List.duplicate(empty_line, bottom)
            end

          current_height > s.height ->
            Enum.take(lines, s.height)

          true ->
            lines
        end
      else
        lines
      end

    Enum.join(lines, "\n")
  end

  defp display_width(string) do
    string
    |> String.replace(~r/\e\[[0-9;]*m/, "")
    |> String.length()
  end

  defp truncate_to_width(string, width) do
    string
    |> String.graphemes()
    |> Enum.reduce_while({"", 0}, fn char, {acc, len} ->
      if len >= width do
        {:halt, {acc, len}}
      else
        {:cont, {acc <> char, len + 1}}
      end
    end)
    |> elem(0)
  end
end
