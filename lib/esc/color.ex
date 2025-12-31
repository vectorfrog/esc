defmodule Esc.Color do
  @moduledoc """
  Color handling for terminal output.

  ## Color Formats

  Esc supports multiple color formats:

  - **Named ANSI colors**: `:red`, `:green`, `:blue`, etc.
  - **ANSI 256 palette**: integers 0-255
  - **True color (24-bit)**: `{r, g, b}` tuples or hex strings like `"#ff0000"`

  ## Adaptive Colors

  Adaptive colors automatically select between two color options based on
  whether the terminal has a light or dark background:

      color = Color.adaptive("#000000", "#ffffff")
      # Uses dark text on light backgrounds, light text on dark backgrounds

  ## Complete Colors

  Complete colors specify exact values for each color profile level,
  preventing automatic degradation:

      color = Color.complete(
        ansi: :red,
        ansi256: 196,
        true_color: {255, 0, 0}
      )

  ## Color Degradation

  When a terminal doesn't support a color profile, colors are automatically
  degraded to the best available alternative using `rgb_to_ansi256/3` and
  `ansi256_to_ansi16/1`.
  """

  @ansi_colors %{
    black: 0,
    red: 1,
    green: 2,
    yellow: 3,
    blue: 4,
    magenta: 5,
    cyan: 6,
    white: 7,
    bright_black: 8,
    bright_red: 9,
    bright_green: 10,
    bright_yellow: 11,
    bright_blue: 12,
    bright_magenta: 13,
    bright_cyan: 14,
    bright_white: 15
  }

  # Adaptive color struct
  defmodule Adaptive do
    @moduledoc """
    Represents an adaptive color that changes based on terminal background.
    """
    defstruct [:light, :dark]

    @type t :: %__MODULE__{
            light: Esc.Style.color(),
            dark: Esc.Style.color()
          }
  end

  # Complete color struct
  defmodule Complete do
    @moduledoc """
    Represents a color with explicit values for each profile level.
    """
    defstruct [:ansi, :ansi256, :true_color]

    @type t :: %__MODULE__{
            ansi: atom() | nil,
            ansi256: integer() | nil,
            true_color: {integer(), integer(), integer()} | nil
          }
  end

  @doc """
  Creates an adaptive color that selects between light and dark variants.

  The `light` variant is used when the terminal has a light background.
  The `dark` variant is used when the terminal has a dark background.

  ## Examples

      iex> Color.adaptive("#000000", "#ffffff")
      %Color.Adaptive{light: "#000000", dark: "#ffffff"}
  """
  @spec adaptive(Esc.Style.color(), Esc.Style.color()) :: Adaptive.t()
  def adaptive(light, dark) do
    %Adaptive{light: light, dark: dark}
  end

  @doc """
  Resolves an adaptive color based on the background mode.

  ## Examples

      iex> color = Color.adaptive(:black, :white)
      iex> Color.resolve_adaptive(color, :light)
      :black
      iex> Color.resolve_adaptive(color, :dark)
      :white
  """
  @spec resolve_adaptive(Adaptive.t(), :light | :dark) :: Esc.Style.color()
  def resolve_adaptive(%Adaptive{light: light}, :light), do: light
  def resolve_adaptive(%Adaptive{dark: dark}, :dark), do: dark

  @doc """
  Creates a complete color with explicit values for each profile level.

  ## Options

  - `:ansi` - Color for basic 16-color terminals (atom like `:red`)
  - `:ansi256` - Color for 256-color terminals (integer 0-255)
  - `:true_color` - Color for true color terminals (RGB tuple or hex string)

  ## Examples

      iex> Color.complete(ansi: :red, ansi256: 196, true_color: {255, 0, 0})
      %Color.Complete{ansi: :red, ansi256: 196, true_color: {255, 0, 0}}
  """
  @spec complete(keyword()) :: Complete.t()
  def complete(opts) do
    %Complete{
      ansi: Keyword.get(opts, :ansi),
      ansi256: Keyword.get(opts, :ansi256),
      true_color: Keyword.get(opts, :true_color)
    }
  end

  @doc """
  Resolves a complete color for a specific profile level.

  Falls back to lower profile levels if the requested level is not specified.

  ## Examples

      iex> color = Color.complete(ansi: :red, true_color: {255, 0, 0})
      iex> Color.resolve_complete(color, :ansi256)
      :red  # Falls back to ansi since ansi256 not specified
  """
  @spec resolve_complete(Complete.t(), :ansi | :ansi256 | :true_color) :: Esc.Style.color() | nil
  def resolve_complete(%Complete{} = color, :true_color) do
    color.true_color || color.ansi256 || color.ansi
  end

  def resolve_complete(%Complete{} = color, :ansi256) do
    color.ansi256 || color.ansi
  end

  def resolve_complete(%Complete{} = color, :ansi) do
    color.ansi
  end

  @doc """
  Converts a color value to ANSI escape sequence for foreground.
  """
  @spec foreground(atom() | integer() | {integer(), integer(), integer()} | String.t()) ::
          String.t()
  def foreground(color) when is_atom(color) do
    case Map.get(@ansi_colors, color) do
      nil -> ""
      n when n < 8 -> "\e[#{30 + n}m"
      n -> "\e[38;5;#{n}m"
    end
  end

  def foreground(n) when is_integer(n) and n >= 0 and n <= 255 do
    "\e[38;5;#{n}m"
  end

  def foreground({r, g, b}) when r in 0..255 and g in 0..255 and b in 0..255 do
    "\e[38;2;#{r};#{g};#{b}m"
  end

  def foreground("#" <> hex) when byte_size(hex) == 6 do
    case hex_to_rgb(hex) do
      {:ok, rgb} -> foreground(rgb)
      :error -> ""
    end
  end

  def foreground(_), do: ""

  @doc """
  Converts a color value to ANSI escape sequence for background.
  """
  @spec background(atom() | integer() | {integer(), integer(), integer()} | String.t()) ::
          String.t()
  def background(color) when is_atom(color) do
    case Map.get(@ansi_colors, color) do
      nil -> ""
      n when n < 8 -> "\e[#{40 + n}m"
      n -> "\e[48;5;#{n}m"
    end
  end

  def background(n) when is_integer(n) and n >= 0 and n <= 255 do
    "\e[48;5;#{n}m"
  end

  def background({r, g, b}) when r in 0..255 and g in 0..255 and b in 0..255 do
    "\e[48;2;#{r};#{g};#{b}m"
  end

  def background("#" <> hex) when byte_size(hex) == 6 do
    case hex_to_rgb(hex) do
      {:ok, rgb} -> background(rgb)
      :error -> ""
    end
  end

  def background(_), do: ""

  @doc """
  Converts an RGB color to the nearest ANSI 256 palette color.

  The ANSI 256 palette consists of:
  - 0-15: Standard colors (same as ANSI 16)
  - 16-231: 6x6x6 color cube
  - 232-255: Grayscale ramp

  ## Examples

      iex> Color.rgb_to_ansi256(255, 0, 0)
      196  # Bright red in the color cube

      iex> Color.rgb_to_ansi256(128, 128, 128)
      244  # Gray in the grayscale ramp
  """
  @spec rgb_to_ansi256(integer(), integer(), integer()) :: integer()
  def rgb_to_ansi256(r, g, b) when r in 0..255 and g in 0..255 and b in 0..255 do
    # Check if it's close to grayscale
    if grayscale?(r, g, b) do
      rgb_to_grayscale(r, g, b)
    else
      rgb_to_color_cube(r, g, b)
    end
  end

  defp grayscale?(r, g, b) do
    avg = div(r + g + b, 3)
    abs(r - avg) < 10 && abs(g - avg) < 10 && abs(b - avg) < 10
  end

  defp rgb_to_grayscale(r, g, b) do
    avg = div(r + g + b, 3)

    cond do
      avg < 8 -> 16   # Black
      avg > 248 -> 231  # White
      true ->
        # Grayscale ramp is 232-255 (24 shades)
        # Each step is about 10 units (256/24 ≈ 10.67)
        232 + div(avg - 8, 10)
    end
  end

  defp rgb_to_color_cube(r, g, b) do
    # 6x6x6 color cube starts at index 16
    # Each channel maps 0-255 to 0-5
    ri = color_cube_index(r)
    gi = color_cube_index(g)
    bi = color_cube_index(b)
    16 + (36 * ri) + (6 * gi) + bi
  end

  defp color_cube_index(value) do
    # The 6 levels are: 0, 95, 135, 175, 215, 255
    cond do
      value < 48 -> 0
      value < 115 -> 1
      value < 155 -> 2
      value < 195 -> 3
      value < 235 -> 4
      true -> 5
    end
  end

  @doc """
  Converts an ANSI 256 palette color to the nearest ANSI 16 color.

  ## Examples

      iex> Color.ansi256_to_ansi16(196)
      1  # Red

      iex> Color.ansi256_to_ansi16(21)
      4  # Blue
  """
  @spec ansi256_to_ansi16(integer()) :: integer()
  def ansi256_to_ansi16(n) when n in 0..15, do: n

  def ansi256_to_ansi16(n) when n in 232..255 do
    # Grayscale ramp
    gray = n - 232
    cond do
      gray < 6 -> 0   # Black
      gray < 18 -> 7  # White (light gray)
      true -> 15      # Bright white
    end
  end

  def ansi256_to_ansi16(n) when n in 16..231 do
    # Color cube - convert back to RGB then find nearest ANSI color
    n = n - 16
    b = rem(n, 6)
    g = rem(div(n, 6), 6)
    r = div(n, 36)

    # Convert 0-5 levels to approximate RGB
    to_rgb = fn level -> if level == 0, do: 0, else: 55 + level * 40 end

    rgb = {to_rgb.(r), to_rgb.(g), to_rgb.(b)}
    nearest_ansi16(rgb)
  end

  defp nearest_ansi16({r, g, b}) do
    # Find which basic color is closest
    colors = [
      {0, {0, 0, 0}},       # black
      {1, {170, 0, 0}},     # red
      {2, {0, 170, 0}},     # green
      {3, {170, 85, 0}},    # yellow/brown
      {4, {0, 0, 170}},     # blue
      {5, {170, 0, 170}},   # magenta
      {6, {0, 170, 170}},   # cyan
      {7, {170, 170, 170}}, # white
      {8, {85, 85, 85}},    # bright black
      {9, {255, 85, 85}},   # bright red
      {10, {85, 255, 85}},  # bright green
      {11, {255, 255, 85}}, # bright yellow
      {12, {85, 85, 255}},  # bright blue
      {13, {255, 85, 255}}, # bright magenta
      {14, {85, 255, 255}}, # bright cyan
      {15, {255, 255, 255}} # bright white
    ]

    {index, _} = Enum.min_by(colors, fn {_idx, {cr, cg, cb}} ->
      # Euclidean distance in RGB space
      :math.sqrt(:math.pow(r - cr, 2) + :math.pow(g - cg, 2) + :math.pow(b - cb, 2))
    end)

    index
  end

  # Parse hex string to RGB tuple, returns {:ok, tuple} or :error
  defp hex_to_rgb(hex) do
    with {r, ""} <- Integer.parse(String.slice(hex, 0, 2), 16),
         {g, ""} <- Integer.parse(String.slice(hex, 2, 2), 16),
         {b, ""} <- Integer.parse(String.slice(hex, 4, 2), 16) do
      {:ok, {r, g, b}}
    else
      _ -> :error
    end
  end
end
