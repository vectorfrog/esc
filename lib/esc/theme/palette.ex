defmodule Esc.Theme.Palette do
  @moduledoc """
  Built-in theme palettes based on popular terminal color schemes.

  All themes are derived from iTerm2 color scheme files with RGB values
  converted from float (0.0-1.0) to integer (0-255) format.

  ## Available Themes

  - `:dracula` - Dark theme with purple/pink accents
  - `:nord` - Arctic, bluish theme with pastel colors
  - `:gruvbox` - Retro groove with warm earth tones
  - `:one` - Atom One Dark inspired theme
  - `:solarized` - Solarized Dark with higher contrast
  - `:monokai` - Classic Monokai color scheme
  - `:material` - Material Design dark theme
  - `:github` - GitHub's light color scheme
  - `:aura` - Dark theme with purple/teal accents
  - `:dolphin` - Blue Dolphin ocean-inspired theme
  - `:chalk` - Chalkboard-style muted colors
  - `:cobalt` - Cobalt Next Dark theme
  """

  alias Esc.Theme

  @themes [:dracula, :nord, :gruvbox, :one, :solarized, :monokai,
           :material, :github, :aura, :dolphin, :chalk, :cobalt]

  @doc """
  Returns all available theme names.

  ## Examples

      iex> Esc.Theme.Palette.list()
      [:dracula, :nord, :gruvbox, :one, :solarized, :monokai,
       :material, :github, :aura, :dolphin, :chalk, :cobalt]
  """
  @spec list() :: [atom()]
  def list, do: @themes

  @doc """
  Returns a theme by name.

  Returns `nil` if the theme name is not recognized.

  ## Examples

      iex> theme = Esc.Theme.Palette.get(:nord)
      iex> theme.name
      :nord

      iex> Esc.Theme.Palette.get(:unknown)
      nil
  """
  @spec get(atom()) :: Theme.t() | nil

  def get(:dracula) do
    %Theme{
      name: :dracula,
      ansi_0: {33, 34, 44},
      ansi_1: {255, 85, 85},
      ansi_2: {80, 250, 123},
      ansi_3: {241, 250, 140},
      ansi_4: {189, 147, 249},
      ansi_5: {255, 121, 198},
      ansi_6: {139, 233, 253},
      ansi_7: {248, 248, 242},
      ansi_8: {98, 114, 164},
      ansi_9: {255, 110, 110},
      ansi_10: {105, 255, 148},
      ansi_11: {255, 255, 165},
      ansi_12: {214, 172, 255},
      ansi_13: {255, 146, 223},
      ansi_14: {164, 255, 255},
      ansi_15: {255, 255, 255},
      background: {40, 42, 54},
      foreground: {248, 248, 242}
    }
  end

  def get(:nord) do
    %Theme{
      name: :nord,
      # Polar Night
      ansi_0: {59, 66, 82},
      ansi_8: {76, 86, 106},
      # Snow Storm
      ansi_7: {216, 222, 233},
      ansi_15: {236, 239, 244},
      # Frost
      ansi_4: {129, 161, 193},
      ansi_12: {94, 129, 172},
      ansi_6: {136, 192, 208},
      ansi_14: {143, 188, 187},
      # Aurora
      ansi_1: {191, 97, 106},
      ansi_9: {191, 97, 106},
      ansi_2: {163, 190, 140},
      ansi_10: {163, 190, 140},
      ansi_3: {235, 203, 139},
      ansi_11: {235, 203, 139},
      ansi_5: {180, 142, 173},
      ansi_13: {180, 142, 173},
      background: {46, 52, 64},
      foreground: {216, 222, 233}
    }
  end

  def get(:gruvbox) do
    %Theme{
      name: :gruvbox,
      ansi_0: {40, 40, 40},
      ansi_1: {204, 36, 29},
      ansi_2: {152, 151, 26},
      ansi_3: {215, 153, 33},
      ansi_4: {69, 133, 136},
      ansi_5: {177, 98, 134},
      ansi_6: {104, 157, 106},
      ansi_7: {168, 153, 132},
      ansi_8: {146, 131, 116},
      ansi_9: {251, 73, 52},
      ansi_10: {184, 187, 38},
      ansi_11: {250, 189, 47},
      ansi_12: {131, 165, 152},
      ansi_13: {211, 134, 155},
      ansi_14: {142, 192, 124},
      ansi_15: {235, 219, 178},
      background: {40, 40, 40},
      foreground: {235, 219, 178}
    }
  end

  def get(:one) do
    %Theme{
      name: :one,
      ansi_0: {29, 31, 35},
      ansi_1: {226, 120, 129},
      ansi_2: {152, 195, 121},
      ansi_3: {234, 199, 134},
      ansi_4: {113, 185, 244},
      ansi_5: {200, 139, 218},
      ansi_6: {98, 186, 198},
      ansi_7: {201, 204, 211},
      ansi_8: {74, 80, 90},
      ansi_9: {230, 137, 145},
      ansi_10: {168, 204, 142},
      ansi_11: {237, 207, 151},
      ansi_12: {141, 199, 246},
      ansi_13: {211, 162, 226},
      ansi_14: {120, 196, 206},
      ansi_15: {230, 230, 230},
      background: {33, 37, 43},
      foreground: {230, 230, 230}
    }
  end

  def get(:solarized) do
    %Theme{
      name: :solarized,
      ansi_0: {0, 40, 49},
      ansi_1: {209, 28, 36},
      ansi_2: {108, 190, 108},
      ansi_3: {165, 119, 6},
      ansi_4: {32, 118, 199},
      ansi_5: {198, 28, 111},
      ansi_6: {37, 145, 134},
      ansi_7: {234, 227, 204},
      ansi_8: {0, 100, 136},
      ansi_9: {245, 22, 59},
      ansi_10: {81, 239, 132},
      ansi_11: {178, 126, 40},
      ansi_12: {23, 142, 200},
      ansi_13: {226, 77, 142},
      ansi_14: {0, 179, 158},
      ansi_15: {252, 244, 220},
      background: {0, 30, 39},
      foreground: {156, 194, 194}
    }
  end

  def get(:monokai) do
    %Theme{
      name: :monokai,
      ansi_0: {39, 40, 34},
      ansi_1: {249, 38, 114},
      ansi_2: {166, 226, 46},
      ansi_3: {230, 219, 116},
      ansi_4: {253, 151, 31},
      ansi_5: {174, 129, 255},
      ansi_6: {102, 217, 239},
      ansi_7: {253, 255, 241},
      ansi_8: {110, 112, 102},
      ansi_9: {249, 38, 114},
      ansi_10: {166, 226, 46},
      ansi_11: {230, 219, 116},
      ansi_12: {253, 151, 31},
      ansi_13: {174, 129, 255},
      ansi_14: {102, 217, 239},
      ansi_15: {253, 255, 241},
      background: {39, 40, 34},
      foreground: {253, 255, 241}
    }
  end

  def get(:material) do
    %Theme{
      name: :material,
      ansi_0: {33, 33, 33},
      ansi_1: {183, 20, 31},
      ansi_2: {69, 123, 36},
      ansi_3: {245, 152, 30},
      ansi_4: {19, 78, 179},
      ansi_5: {86, 0, 136},
      ansi_6: {14, 113, 124},
      ansi_7: {239, 239, 239},
      ansi_8: {66, 66, 66},
      ansi_9: {232, 59, 63},
      ansi_10: {122, 186, 58},
      ansi_11: {255, 234, 46},
      ansi_12: {84, 164, 244},
      ansi_13: {170, 77, 188},
      ansi_14: {38, 187, 209},
      ansi_15: {217, 217, 217},
      background: {35, 35, 34},
      foreground: {229, 229, 229}
    }
  end

  def get(:github) do
    %Theme{
      name: :github,
      ansi_0: {62, 62, 62},
      ansi_1: {151, 11, 22},
      ansi_2: {7, 150, 42},
      ansi_3: {248, 238, 199},
      ansi_4: {0, 62, 138},
      ansi_5: {233, 70, 145},
      ansi_6: {137, 209, 236},
      ansi_7: {255, 255, 255},
      ansi_8: {102, 102, 102},
      ansi_9: {222, 0, 0},
      ansi_10: {135, 213, 162},
      ansi_11: {241, 208, 7},
      ansi_12: {46, 108, 186},
      ansi_13: {255, 162, 159},
      ansi_14: {28, 250, 254},
      ansi_15: {255, 255, 255},
      background: {244, 244, 244},
      foreground: {62, 62, 62}
    }
  end

  def get(:aura) do
    %Theme{
      name: :aura,
      ansi_0: {17, 15, 24},
      ansi_1: {255, 103, 103},
      ansi_2: {97, 255, 202},
      ansi_3: {255, 202, 133},
      ansi_4: {162, 119, 255},
      ansi_5: {162, 119, 255},
      ansi_6: {97, 255, 202},
      ansi_7: {237, 236, 238},
      ansi_8: {77, 77, 77},
      ansi_9: {255, 202, 133},
      ansi_10: {162, 119, 255},
      ansi_11: {255, 202, 133},
      ansi_12: {162, 119, 255},
      ansi_13: {162, 119, 255},
      ansi_14: {97, 255, 202},
      ansi_15: {237, 236, 238},
      background: {21, 20, 27},
      foreground: {237, 236, 238}
    }
  end

  def get(:dolphin) do
    %Theme{
      name: :dolphin,
      ansi_0: {41, 45, 62},
      ansi_1: {255, 130, 137},
      ansi_2: {180, 232, 141},
      ansi_3: {244, 214, 159},
      ansi_4: {130, 170, 255},
      ansi_5: {233, 193, 255},
      ansi_6: {137, 235, 255},
      ansi_7: {208, 208, 208},
      ansi_8: {67, 71, 88},
      ansi_9: {255, 139, 146},
      ansi_10: {221, 255, 167},
      ansi_11: {255, 229, 133},
      ansi_12: {156, 196, 255},
      ansi_13: {221, 176, 246},
      ansi_14: {163, 247, 255},
      ansi_15: {255, 255, 255},
      background: {0, 105, 132},
      foreground: {197, 242, 255}
    }
  end

  def get(:chalk) do
    %Theme{
      name: :chalk,
      ansi_0: {0, 0, 0},
      ansi_1: {195, 115, 114},
      ansi_2: {114, 195, 115},
      ansi_3: {194, 195, 114},
      ansi_4: {115, 114, 195},
      ansi_5: {195, 114, 194},
      ansi_6: {114, 194, 195},
      ansi_7: {217, 217, 217},
      ansi_8: {50, 50, 50},
      ansi_9: {219, 170, 170},
      ansi_10: {170, 219, 170},
      ansi_11: {218, 219, 170},
      ansi_12: {170, 170, 219},
      ansi_13: {219, 170, 218},
      ansi_14: {170, 218, 219},
      ansi_15: {255, 255, 255},
      background: {41, 38, 47},
      foreground: {217, 230, 242}
    }
  end

  def get(:cobalt) do
    %Theme{
      name: :cobalt,
      ansi_0: {40, 47, 54},
      ansi_1: {230, 87, 106},
      ansi_2: {153, 199, 148},
      ansi_3: {250, 200, 99},
      ansi_4: {90, 155, 207},
      ansi_5: {197, 165, 197},
      ansi_6: {95, 179, 179},
      ansi_7: {216, 222, 233},
      ansi_8: {101, 115, 126},
      ansi_9: {214, 131, 140},
      ansi_10: {193, 220, 190},
      ansi_11: {255, 222, 155},
      ansi_12: {138, 190, 231},
      ansi_13: {237, 205, 237},
      ansi_14: {155, 226, 226},
      ansi_15: {255, 255, 255},
      background: {15, 28, 35},
      foreground: {216, 222, 233}
    }
  end

  def get(_), do: nil
end
