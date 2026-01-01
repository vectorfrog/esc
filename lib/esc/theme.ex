defmodule Esc.Theme do
  @moduledoc """
  Theme definitions for terminal styling.

  Themes provide a consistent color palette including:
  - 16 ANSI colors (ansi_0 through ansi_15)
  - Background and foreground colors
  - Semantic colors for common UI purposes

  ## Semantic Colors

  Semantic colors provide meaningful names for common use cases:
  - `:header` - Headers, titles (defaults to cyan/ansi_6)
  - `:emphasis` - Important text (defaults to blue/ansi_4)
  - `:warning` - Warning messages (defaults to yellow/ansi_3)
  - `:error` - Error messages (defaults to red/ansi_1)
  - `:success` - Success messages (defaults to green/ansi_2)
  - `:muted` - Subdued text, borders (defaults to bright black/ansi_8)

  ## Usage

      Esc.set_theme(:nord)

      # Use semantic colors in styles
      style() |> theme_foreground(:error) |> render("Error!")
  """

  @type rgb :: {0..255, 0..255, 0..255}

  @type t :: %__MODULE__{
          name: atom(),
          # Standard ANSI 16 colors
          ansi_0: rgb(),
          ansi_1: rgb(),
          ansi_2: rgb(),
          ansi_3: rgb(),
          ansi_4: rgb(),
          ansi_5: rgb(),
          ansi_6: rgb(),
          ansi_7: rgb(),
          ansi_8: rgb(),
          ansi_9: rgb(),
          ansi_10: rgb(),
          ansi_11: rgb(),
          ansi_12: rgb(),
          ansi_13: rgb(),
          ansi_14: rgb(),
          ansi_15: rgb(),
          # Terminal colors
          background: rgb(),
          foreground: rgb(),
          # Semantic colors (nil = derive from ANSI)
          header: rgb() | nil,
          emphasis: rgb() | nil,
          warning: rgb() | nil,
          error: rgb() | nil,
          success: rgb() | nil,
          muted: rgb() | nil
        }

  defstruct [
    :name,
    # Standard ANSI 16 colors
    :ansi_0,
    :ansi_1,
    :ansi_2,
    :ansi_3,
    :ansi_4,
    :ansi_5,
    :ansi_6,
    :ansi_7,
    :ansi_8,
    :ansi_9,
    :ansi_10,
    :ansi_11,
    :ansi_12,
    :ansi_13,
    :ansi_14,
    :ansi_15,
    # Terminal colors
    :background,
    :foreground,
    # Semantic colors
    :header,
    :emphasis,
    :warning,
    :error,
    :success,
    :muted
  ]

  @doc """
  Gets a color from a theme by name.

  Handles both direct palette colors (ansi_0..ansi_15, background, foreground)
  and semantic colors (header, emphasis, warning, error, success, muted).

  Semantic colors are derived from the ANSI palette if not explicitly set.

  ## Examples

      iex> theme = Esc.Theme.Palette.get(:nord)
      iex> Esc.Theme.color(theme, :error)
      {191, 97, 106}

      iex> Esc.Theme.color(theme, :ansi_4)
      {129, 161, 193}
  """
  @spec color(t(), atom()) :: rgb() | nil
  def color(%__MODULE__{} = theme, name) do
    case Map.get(theme, name) do
      nil -> derive_semantic_color(theme, name)
      color -> color
    end
  end

  # Default semantic color derivations from ANSI palette
  defp derive_semantic_color(theme, :header), do: theme.ansi_6
  defp derive_semantic_color(theme, :emphasis), do: theme.ansi_4
  defp derive_semantic_color(theme, :warning), do: theme.ansi_3
  defp derive_semantic_color(theme, :error), do: theme.ansi_1
  defp derive_semantic_color(theme, :success), do: theme.ansi_2
  defp derive_semantic_color(theme, :muted), do: theme.ansi_8
  defp derive_semantic_color(_theme, _name), do: nil
end
