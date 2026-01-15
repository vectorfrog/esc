defmodule Esc.ThemeStyleTest do
  use ExUnit.Case, async: true

  import Esc
  alias Esc.Theme

  describe "style/1 with theme" do
    test "attaches theme struct when passed as argument" do
      theme = Theme.Palette.get(:nord)
      style = style(theme)

      assert style.theme == theme
    end

    test "looks up theme from palette when passed as atom" do
      style = style(:nord)

      assert style.theme != nil
      assert style.theme.name == :nord
    end

    test "returns style with nil theme when no argument provided" do
      style = style()

      assert style.theme == nil
    end

    test "raises ArgumentError for unknown theme" do
      assert_raise ArgumentError, fn ->
        style(:unknown_theme)
      end
    end
  end

  describe "foreground/2 with theme - ANSI color atoms" do
    test "resolves :red to Nord's ansi_1 RGB tuple" do
      style_result = style(:nord) |> foreground(:red)

      assert style_result.foreground == {191, 97, 106}
    end

    test "resolves :bright_magenta to Dracula's ansi_13 RGB tuple" do
      style_result = style(:dracula) |> foreground(:bright_magenta)

      assert style_result.foreground == {255, 146, 223}
    end

    test "resolves :green to Nord's ansi_2 RGB tuple" do
      style_result = style(:nord) |> foreground(:green)

      assert style_result.foreground == {163, 190, 140}
    end

    test "resolves :bright_blue to Nord's ansi_12 RGB tuple" do
      style_result = style(:nord) |> foreground(:bright_blue)

      assert style_result.foreground == {94, 129, 172}
    end

    test "resolves :cyan to Dracula's ansi_6 RGB tuple" do
      style_result = style(:dracula) |> foreground(:cyan)

      assert style_result.foreground == {139, 233, 253}
    end

    test "resolves :yellow to Gruvbox's ansi_3 RGB tuple" do
      style_result = style(:gruvbox) |> foreground(:yellow)

      assert style_result.foreground == {215, 153, 33}
    end
  end

  describe "foreground/2 with theme - semantic colors" do
    test "resolves :error to theme's ansi_1 (red)" do
      style_result = style(:nord) |> foreground(:error)

      assert style_result.foreground == {191, 97, 106}
    end

    test "resolves :success to theme's ansi_2 (green)" do
      style_result = style(:nord) |> foreground(:success)

      assert style_result.foreground == {163, 190, 140}
    end

    test "resolves :warning to theme's ansi_3 (yellow)" do
      style_result = style(:nord) |> foreground(:warning)

      assert style_result.foreground == {235, 203, 139}
    end

    test "resolves :emphasis to theme's ansi_4 (blue)" do
      style_result = style(:nord) |> foreground(:emphasis)

      assert style_result.foreground == {129, 161, 193}
    end

    test "resolves :header to theme's ansi_6 (cyan)" do
      style_result = style(:nord) |> foreground(:header)

      assert style_result.foreground == {136, 192, 208}
    end

    test "resolves :muted to theme's ansi_8 (bright black)" do
      style_result = style(:nord) |> foreground(:muted)

      assert style_result.foreground == {76, 86, 106}
    end
  end

  describe "foreground/2 without theme" do
    test "keeps :red atom when no theme is set" do
      style_result = style() |> foreground(:red)

      assert style_result.foreground == :red
    end

    test "keeps :bright_magenta atom when no theme is set" do
      style_result = style() |> foreground(:bright_magenta)

      assert style_result.foreground == :bright_magenta
    end

    test "keeps :green atom when no theme is set" do
      style_result = style() |> foreground(:green)

      assert style_result.foreground == :green
    end

    test "converts semantic color to ANSI when no theme is set" do
      style_result = style() |> foreground(:error)

      assert style_result.foreground == :red
    end
  end

  describe "foreground/2 with theme - non-atom colors pass through" do
    test "hex string passes through unchanged" do
      style_result = style(:nord) |> foreground("#ff0000")

      assert style_result.foreground == "#ff0000"
    end

    test "RGB tuple passes through unchanged" do
      style_result = style(:nord) |> foreground({255, 0, 0})

      assert style_result.foreground == {255, 0, 0}
    end

    test "integer color code passes through unchanged" do
      style_result = style(:nord) |> foreground(196)

      assert style_result.foreground == 196
    end

    test "hex string passes through with Dracula theme" do
      style_result = style(:dracula) |> foreground("#123456")

      assert style_result.foreground == "#123456"
    end

    test "complex RGB tuple passes through with theme" do
      style_result = style(:nord) |> foreground({128, 64, 32})

      assert style_result.foreground == {128, 64, 32}
    end
  end

  describe "background/2 with theme - ANSI color atoms" do
    test "resolves :red to Nord's ansi_1 RGB tuple" do
      style_result = style(:nord) |> background(:red)

      assert style_result.background == {191, 97, 106}
    end

    test "resolves :bright_magenta to Dracula's ansi_13 RGB tuple" do
      style_result = style(:dracula) |> background(:bright_magenta)

      assert style_result.background == {255, 146, 223}
    end

    test "resolves :blue to Gruvbox's ansi_4 RGB tuple" do
      style_result = style(:gruvbox) |> background(:blue)

      assert style_result.background == {69, 133, 136}
    end

    test "resolves :bright_cyan to Dracula's ansi_14 RGB tuple" do
      style_result = style(:dracula) |> background(:bright_cyan)

      assert style_result.background == {164, 255, 255}
    end
  end

  describe "background/2 with theme - semantic colors" do
    test "resolves :error to theme's ansi_1" do
      style_result = style(:nord) |> background(:error)

      assert style_result.background == {191, 97, 106}
    end

    test "resolves :muted to theme's ansi_8" do
      style_result = style(:dracula) |> background(:muted)

      assert style_result.background == {98, 114, 164}
    end
  end

  describe "background/2 without theme" do
    test "keeps :red atom when no theme is set" do
      style_result = style() |> background(:red)

      assert style_result.background == :red
    end

    test "keeps :bright_magenta atom when no theme is set" do
      style_result = style() |> background(:bright_magenta)

      assert style_result.background == :bright_magenta
    end
  end

  describe "background/2 with theme - non-atom colors pass through" do
    test "hex string passes through unchanged" do
      style_result = style(:nord) |> background("#ff0000")

      assert style_result.background == "#ff0000"
    end

    test "RGB tuple passes through unchanged" do
      style_result = style(:nord) |> background({255, 0, 0})

      assert style_result.background == {255, 0, 0}
    end

    test "integer color code passes through unchanged" do
      style_result = style(:nord) |> background(196)

      assert style_result.background == 196
    end
  end

  describe "border_foreground/2 with theme - ANSI color atoms" do
    test "resolves :red to Nord's ansi_1 RGB tuple" do
      style_result = style(:nord) |> border_foreground(:red)

      assert style_result.border_foreground == {191, 97, 106}
    end

    test "resolves :bright_magenta to Dracula's ansi_13 RGB tuple" do
      style_result = style(:dracula) |> border_foreground(:bright_magenta)

      assert style_result.border_foreground == {255, 146, 223}
    end

    test "resolves :magenta to Nord's ansi_5 RGB tuple" do
      style_result = style(:nord) |> border_foreground(:magenta)

      assert style_result.border_foreground == {180, 142, 173}
    end

    test "resolves :bright_yellow to Gruvbox's ansi_11 RGB tuple" do
      style_result = style(:gruvbox) |> border_foreground(:bright_yellow)

      assert style_result.border_foreground == {250, 189, 47}
    end
  end

  describe "border_foreground/2 with theme - semantic colors" do
    test "resolves :muted to theme's ansi_8" do
      style_result = style(:nord) |> border_foreground(:muted)

      assert style_result.border_foreground == {76, 86, 106}
    end

    test "resolves :header to theme's ansi_6" do
      style_result = style(:dracula) |> border_foreground(:header)

      assert style_result.border_foreground == {139, 233, 253}
    end
  end

  describe "border_foreground/2 without theme" do
    test "keeps :red atom when no theme is set" do
      style_result = style() |> border_foreground(:red)

      assert style_result.border_foreground == :red
    end

    test "keeps :bright_magenta atom when no theme is set" do
      style_result = style() |> border_foreground(:bright_magenta)

      assert style_result.border_foreground == :bright_magenta
    end

    test "converts semantic color to ANSI when no theme is set" do
      style_result = style() |> border_foreground(:muted)

      assert style_result.border_foreground == :bright_black
    end
  end

  describe "border_foreground/2 with theme - non-atom colors pass through" do
    test "hex string passes through unchanged" do
      style_result = style(:nord) |> border_foreground("#ff0000")

      assert style_result.border_foreground == "#ff0000"
    end

    test "RGB tuple passes through unchanged" do
      style_result = style(:nord) |> border_foreground({255, 0, 0})

      assert style_result.border_foreground == {255, 0, 0}
    end

    test "integer color code passes through unchanged" do
      style_result = style(:nord) |> border_foreground(196)

      assert style_result.border_foreground == 196
    end
  end

  describe "border_background/2 with theme - ANSI color atoms" do
    test "resolves :black to Nord's ansi_0 RGB tuple" do
      style_result = style(:nord) |> border_background(:black)

      assert style_result.border_background == {59, 66, 82}
    end

    test "resolves :white to Dracula's ansi_7 RGB tuple" do
      style_result = style(:dracula) |> border_background(:white)

      assert style_result.border_background == {248, 248, 242}
    end
  end

  describe "border_background/2 without theme" do
    test "keeps :black atom when no theme is set" do
      style_result = style() |> border_background(:black)

      assert style_result.border_background == :black
    end
  end

  describe "border_background/2 with theme - non-atom colors pass through" do
    test "hex string passes through unchanged" do
      style_result = style(:nord) |> border_background("#ff0000")

      assert style_result.border_background == "#ff0000"
    end

    test "RGB tuple passes through unchanged" do
      style_result = style(:nord) |> border_background({255, 0, 0})

      assert style_result.border_background == {255, 0, 0}
    end

    test "integer color code passes through unchanged" do
      style_result = style(:nord) |> border_background(196)

      assert style_result.border_background == 196
    end
  end

  describe "edge cases" do
    test "unknown color atom with theme falls back to atom" do
      style_result = style(:nord) |> foreground(:unknown_color)

      # Unknown atoms should be kept as-is for ANSI fallback
      assert style_result.foreground == :unknown_color
    end

    test "nil color is preserved with theme" do
      style_result = style(:nord) |> foreground(nil)

      assert style_result.foreground == nil
    end

    test "chaining multiple color operations with theme" do
      style_result =
        style(:nord)
        |> foreground(:red)
        |> background(:blue)
        |> border_foreground(:muted)

      assert style_result.foreground == {191, 97, 106}
      assert style_result.background == {129, 161, 193}
      assert style_result.border_foreground == {76, 86, 106}
    end

    test "mixing themed and non-themed colors in one style" do
      style_result =
        style(:nord)
        |> foreground(:red)
        |> background("#123456")
        |> border_foreground(196)

      assert style_result.foreground == {191, 97, 106}
      assert style_result.background == "#123456"
      assert style_result.border_foreground == 196
    end
  end

  describe "multiple themes" do
    test "different themes resolve same color atom differently" do
      nord_style = style(:nord) |> foreground(:red)
      dracula_style = style(:dracula) |> foreground(:red)
      gruvbox_style = style(:gruvbox) |> foreground(:red)

      assert nord_style.foreground == {191, 97, 106}
      assert dracula_style.foreground == {255, 85, 85}
      assert gruvbox_style.foreground == {204, 36, 29}
    end

    test "bright colors resolve differently across themes" do
      nord_bright_red = style(:nord) |> foreground(:bright_red)
      dracula_bright_red = style(:dracula) |> foreground(:bright_red)

      # Nord uses same color for red and bright_red
      assert nord_bright_red.foreground == {191, 97, 106}
      # Dracula has distinct bright_red
      assert dracula_bright_red.foreground == {255, 110, 110}
    end
  end

  describe "all 16 ANSI colors with theme" do
    test "resolves all basic colors (0-7)" do
      style_result =
        style(:nord)
        |> foreground(:black)

      assert style_result.foreground == {59, 66, 82}

      style_result = style(:nord) |> foreground(:red)
      assert style_result.foreground == {191, 97, 106}

      style_result = style(:nord) |> foreground(:green)
      assert style_result.foreground == {163, 190, 140}

      style_result = style(:nord) |> foreground(:yellow)
      assert style_result.foreground == {235, 203, 139}

      style_result = style(:nord) |> foreground(:blue)
      assert style_result.foreground == {129, 161, 193}

      style_result = style(:nord) |> foreground(:magenta)
      assert style_result.foreground == {180, 142, 173}

      style_result = style(:nord) |> foreground(:cyan)
      assert style_result.foreground == {136, 192, 208}

      style_result = style(:nord) |> foreground(:white)
      assert style_result.foreground == {216, 222, 233}
    end

    test "resolves all bright colors (8-15)" do
      style_result = style(:nord) |> foreground(:bright_black)
      assert style_result.foreground == {76, 86, 106}

      style_result = style(:nord) |> foreground(:bright_red)
      assert style_result.foreground == {191, 97, 106}

      style_result = style(:nord) |> foreground(:bright_green)
      assert style_result.foreground == {163, 190, 140}

      style_result = style(:nord) |> foreground(:bright_yellow)
      assert style_result.foreground == {235, 203, 139}

      style_result = style(:nord) |> foreground(:bright_blue)
      assert style_result.foreground == {94, 129, 172}

      style_result = style(:nord) |> foreground(:bright_magenta)
      assert style_result.foreground == {180, 142, 173}

      style_result = style(:nord) |> foreground(:bright_cyan)
      assert style_result.foreground == {143, 188, 187}

      style_result = style(:nord) |> foreground(:bright_white)
      assert style_result.foreground == {236, 239, 244}
    end
  end

  describe "theme field colors" do
    test "resolves :foreground to theme's foreground color" do
      style_result = style(:nord) |> foreground(:foreground)

      assert style_result.foreground == {216, 222, 233}
    end

    test "resolves :background to theme's background color" do
      style_result = style(:dracula) |> foreground(:background)

      assert style_result.foreground == {40, 42, 54}
    end
  end

  # ============================================================================
  # SEMANTIC COLOR FALLBACKS
  # Tests for semantic color resolution behavior from spec
  # ============================================================================

  describe "semantic colors - foreground with theme" do
    setup do
      theme = Theme.Palette.get(:nord)
      {:ok, theme: theme}
    end

    test "resolves :error through theme to ansi_1", %{theme: theme} do
      style = style(:nord) |> foreground(:error)

      assert style.foreground == theme.ansi_1
      assert style.foreground == {191, 97, 106}
    end

    test "resolves :success through theme to ansi_2", %{theme: theme} do
      style = style(:nord) |> foreground(:success)

      assert style.foreground == theme.ansi_2
      assert style.foreground == {163, 190, 140}
    end

    test "resolves :warning through theme to ansi_3", %{theme: theme} do
      style = style(:nord) |> foreground(:warning)

      assert style.foreground == theme.ansi_3
      assert style.foreground == {235, 203, 139}
    end

    test "resolves :emphasis through theme to ansi_4", %{theme: theme} do
      style = style(:nord) |> foreground(:emphasis)

      assert style.foreground == theme.ansi_4
      assert style.foreground == {129, 161, 193}
    end

    test "resolves :header through theme to ansi_6", %{theme: theme} do
      style = style(:nord) |> foreground(:header)

      assert style.foreground == theme.ansi_6
      assert style.foreground == {136, 192, 208}
    end

    test "resolves :muted through theme to ansi_8", %{theme: theme} do
      style = style(:nord) |> foreground(:muted)

      assert style.foreground == theme.ansi_8
      assert style.foreground == {76, 86, 106}
    end
  end

  describe "semantic colors - foreground without theme (ANSI fallback)" do
    test "converts :error to :red for ANSI fallback" do
      style = style() |> foreground(:error)

      assert style.foreground == :red
    end

    test "converts :success to :green for ANSI fallback" do
      style = style() |> foreground(:success)

      assert style.foreground == :green
    end

    test "converts :warning to :yellow for ANSI fallback" do
      style = style() |> foreground(:warning)

      assert style.foreground == :yellow
    end

    test "converts :emphasis to :blue for ANSI fallback" do
      style = style() |> foreground(:emphasis)

      assert style.foreground == :blue
    end

    test "converts :header to :cyan for ANSI fallback" do
      style = style() |> foreground(:header)

      assert style.foreground == :cyan
    end

    test "converts :muted to :bright_black for ANSI fallback" do
      style = style() |> foreground(:muted)

      assert style.foreground == :bright_black
    end
  end

  describe "semantic colors - background with theme" do
    test "resolves all semantic colors in background" do
      theme = Theme.Palette.get(:nord)

      assert (style(:nord) |> background(:error)).background == theme.ansi_1
      assert (style(:nord) |> background(:success)).background == theme.ansi_2
      assert (style(:nord) |> background(:warning)).background == theme.ansi_3
      assert (style(:nord) |> background(:emphasis)).background == theme.ansi_4
      assert (style(:nord) |> background(:header)).background == theme.ansi_6
      assert (style(:nord) |> background(:muted)).background == theme.ansi_8
    end
  end

  describe "semantic colors - background without theme (ANSI fallback)" do
    test "converts semantic color atoms to ANSI in background" do
      assert (style() |> background(:error)).background == :red
      assert (style() |> background(:success)).background == :green
      assert (style() |> background(:warning)).background == :yellow
      assert (style() |> background(:emphasis)).background == :blue
      assert (style() |> background(:header)).background == :cyan
      assert (style() |> background(:muted)).background == :bright_black
    end
  end

  describe "semantic colors - border_foreground and border_background" do
    test "resolves semantic colors in border_foreground with theme" do
      theme = Theme.Palette.get(:nord)

      style_error = style(:nord) |> border_foreground(:error)
      style_muted = style(:nord) |> border_foreground(:muted)
      style_header = style(:nord) |> border_foreground(:header)

      assert style_error.border_foreground == theme.ansi_1
      assert style_muted.border_foreground == theme.ansi_8
      assert style_header.border_foreground == theme.ansi_6
    end

    test "converts semantic colors to ANSI in border_foreground without theme" do
      assert (style() |> border_foreground(:error)).border_foreground == :red
      assert (style() |> border_foreground(:muted)).border_foreground == :bright_black
      assert (style() |> border_foreground(:header)).border_foreground == :cyan
    end

    test "resolves semantic colors in border_background with theme" do
      theme = Theme.Palette.get(:nord)

      style = style(:nord) |> border_background(:emphasis)

      assert style.border_background == theme.ansi_4
    end

    test "converts semantic colors to ANSI in border_background without theme" do
      style = style() |> border_background(:emphasis)

      assert style.border_background == :blue
    end
  end

  describe "Theme.color/2 semantic color derivation" do
    test "derives :error from ansi_1" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :error)

      assert color == theme.ansi_1
      assert color == {191, 97, 106}
    end

    test "derives :success from ansi_2" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :success)

      assert color == theme.ansi_2
      assert color == {163, 190, 140}
    end

    test "derives :warning from ansi_3" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :warning)

      assert color == theme.ansi_3
      assert color == {235, 203, 139}
    end

    test "derives :emphasis from ansi_4" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :emphasis)

      assert color == theme.ansi_4
      assert color == {129, 161, 193}
    end

    test "derives :header from ansi_6" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :header)

      assert color == theme.ansi_6
      assert color == {136, 192, 208}
    end

    test "derives :muted from ansi_8" do
      theme = Theme.Palette.get(:nord)

      color = Theme.color(theme, :muted)

      assert color == theme.ansi_8
      assert color == {76, 86, 106}
    end

    test "returns direct palette colors unchanged" do
      theme = Theme.Palette.get(:nord)

      assert Theme.color(theme, :ansi_0) == theme.ansi_0
      assert Theme.color(theme, :ansi_15) == theme.ansi_15
      assert Theme.color(theme, :foreground) == theme.foreground
      assert Theme.color(theme, :background) == theme.background
    end

    test "returns nil for unknown color name" do
      theme = Theme.Palette.get(:nord)

      assert Theme.color(theme, :nonexistent) == nil
      assert Theme.color(theme, :unknown_semantic) == nil
    end
  end

  describe "semantic colors across all themes" do
    test "all semantic colors resolve for all themes" do
      semantic_colors = [:error, :success, :warning, :emphasis, :header, :muted]

      for theme_name <- Theme.Palette.list(),
          semantic <- semantic_colors do
        theme = Theme.Palette.get(theme_name)

        style = style(theme_name) |> foreground(semantic)
        expected = Theme.color(theme, semantic)

        assert style.foreground == expected,
               "Theme #{inspect(theme_name)} failed to resolve #{inspect(semantic)}"

        assert is_tuple(style.foreground)
        assert tuple_size(style.foreground) == 3
      end
    end

    test "semantic colors produce different RGB values across themes" do
      nord_error = style(:nord) |> foreground(:error)
      dracula_error = style(:dracula) |> foreground(:error)
      gruvbox_error = style(:gruvbox) |> foreground(:error)

      # Nord's error color (ansi_1)
      assert nord_error.foreground == {191, 97, 106}
      # Dracula's error color (ansi_1)
      assert dracula_error.foreground == {255, 85, 85}
      # Gruvbox's error color (ansi_1)
      assert gruvbox_error.foreground == {204, 36, 29}

      # All different
      assert nord_error.foreground != dracula_error.foreground
      assert nord_error.foreground != gruvbox_error.foreground
      assert dracula_error.foreground != gruvbox_error.foreground
    end
  end

  describe "semantic colors - pipeline operations" do
    test "can chain semantic colors with other style operations" do
      theme = Theme.Palette.get(:nord)

      style =
        style(:nord)
        |> foreground(:error)
        |> background(:muted)
        |> bold()
        |> padding(1, 2)

      assert style.foreground == theme.ansi_1
      assert style.background == theme.ansi_8
      assert style.bold == true
      assert style.padding_top == 1
      assert style.padding_left == 2
    end

    test "can override semantic color with explicit RGB" do
      theme = Theme.Palette.get(:nord)

      # First set semantic
      style_semantic = style(:nord) |> foreground(:error)
      assert style_semantic.foreground == theme.ansi_1

      # Then override with RGB
      style_override = style_semantic |> foreground({255, 0, 0})
      assert style_override.foreground == {255, 0, 0}
    end

    test "can mix semantic and standard ANSI colors" do
      theme = Theme.Palette.get(:nord)

      style =
        style(:nord)
        |> foreground(:error)
        |> background(:bright_cyan)

      assert style.foreground == theme.ansi_1
      assert style.background == theme.ansi_14
    end

    test "semantic color followed by unset removes color" do
      style =
        style(:nord)
        |> foreground(:error)
        |> unset_foreground()

      assert style.foreground == nil
    end
  end

  describe "semantic colors - edge cases" do
    test "unknown semantic color with theme keeps atom" do
      style = style(:nord) |> foreground(:unknown_semantic)

      # Should keep atom for potential ANSI fallback
      assert style.foreground == :unknown_semantic
    end

    test "unknown semantic color without theme keeps atom" do
      style = style() |> foreground(:unknown_semantic)

      assert style.foreground == :unknown_semantic
    end

    test "nil color with theme stays nil" do
      # Foreground starts as nil and stays nil when not set
      style_result = style(:nord)

      assert style_result.foreground == nil
    end

    test "empty atom handled correctly" do
      # Empty atom should pass through (not a valid semantic color)
      style_with_theme = style(:nord) |> foreground(:"")
      style_without_theme = style() |> foreground(:"")

      assert style_with_theme.foreground == :""
      assert style_without_theme.foreground == :""
    end
  end

  describe "semantic colors - rendering" do
    test "semantic color with theme renders as true color RGB" do
      theme = Theme.Palette.get(:nord)
      {r, g, b} = theme.ansi_1

      result =
        style(:nord)
        |> foreground(:error)
        |> render("Error message")

      # Should contain RGB true color escape sequence
      assert result =~ "\e[38;2;#{r};#{g};#{b}m"
      assert result =~ "Error message"
    end

    test "semantic color without theme uses ANSI fallback" do
      result =
        style()
        |> foreground(:error)
        |> render("Error message")

      # Should contain message (ANSI behavior depends on Color module)
      assert result =~ "Error message"
    end

    test "multiple semantic colors render correctly" do
      theme = Theme.Palette.get(:nord)
      {fg_r, fg_g, fg_b} = theme.ansi_1
      {bg_r, bg_g, bg_b} = theme.ansi_8

      result =
        style(:nord)
        |> foreground(:error)
        |> background(:muted)
        |> render("Alert")

      # Should contain both RGB sequences
      assert result =~ "\e[38;2;#{fg_r};#{fg_g};#{fg_b}m"
      assert result =~ "\e[48;2;#{bg_r};#{bg_g};#{bg_b}m"
      assert result =~ "Alert"
    end
  end

  describe "semantic colors - special :foreground and :background atoms" do
    test "resolves :foreground semantic color with theme" do
      theme = Theme.Palette.get(:nord)
      style = style(:nord) |> foreground(:foreground)

      assert style.foreground == theme.foreground
      assert style.foreground == {216, 222, 233}
    end

    test "resolves :background semantic color in foreground with theme" do
      theme = Theme.Palette.get(:nord)
      style = style(:nord) |> foreground(:background)

      assert style.foreground == theme.background
      assert style.foreground == {46, 52, 64}
    end

    test "resolves :foreground in background with theme" do
      theme = Theme.Palette.get(:nord)
      style = style(:nord) |> background(:foreground)

      assert style.background == theme.foreground
    end

    test "resolves :background semantic color in background with theme" do
      theme = Theme.Palette.get(:nord)
      style = style(:nord) |> background(:background)

      assert style.background == theme.background
    end

    test "passes through :foreground atom without theme (not a standard ANSI color)" do
      style = style() |> foreground(:foreground)

      # :foreground is not a semantic color, so it passes through as-is
      assert style.foreground == :foreground
    end

    test "passes through :background atom without theme (not a standard ANSI color)" do
      style = style() |> background(:background)

      # :background is not a semantic color, so it passes through as-is
      assert style.background == :background
    end
  end
end
