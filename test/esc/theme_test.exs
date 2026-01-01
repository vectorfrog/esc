defmodule Esc.ThemeTest do
  use ExUnit.Case, async: false

  alias Esc.Theme
  alias Esc.Theme.{Palette, Store}

  setup do
    # Clear theme before each test
    Store.clear()
    :ok
  end

  describe "Theme.Palette" do
    test "list/0 returns all 12 themes" do
      themes = Palette.list()
      assert length(themes) == 12
      assert :dracula in themes
      assert :nord in themes
      assert :gruvbox in themes
      assert :one in themes
      assert :solarized in themes
      assert :monokai in themes
      assert :material in themes
      assert :github in themes
      assert :aura in themes
      assert :dolphin in themes
      assert :chalk in themes
      assert :cobalt in themes
    end

    test "get/1 returns theme struct for valid name" do
      theme = Palette.get(:nord)
      assert %Theme{name: :nord} = theme
      assert is_tuple(theme.ansi_0)
      assert is_tuple(theme.foreground)
      assert is_tuple(theme.background)
    end

    test "get/1 returns nil for unknown theme" do
      assert Palette.get(:unknown) == nil
    end

    test "each theme has all required colors" do
      for name <- Palette.list() do
        theme = Palette.get(name)
        assert theme.name == name
        # Check all ANSI colors
        for i <- 0..15 do
          color = Map.get(theme, :"ansi_#{i}")
          assert is_tuple(color), "#{name} missing ansi_#{i}"
          assert tuple_size(color) == 3
        end
        # Check background/foreground
        assert is_tuple(theme.background)
        assert is_tuple(theme.foreground)
      end
    end
  end

  describe "Theme.Store" do
    test "get/0 returns nil when no theme set" do
      assert Store.get() == nil
    end

    test "set/1 with atom sets theme from palette" do
      assert :ok = Store.set(:nord)
      theme = Store.get()
      assert %Theme{name: :nord} = theme
    end

    test "set/1 with unknown atom returns error" do
      assert {:error, :unknown_theme} = Store.set(:unknown)
    end

    test "set/1 with struct sets custom theme" do
      custom = %Theme{name: :custom, ansi_0: {0, 0, 0}}
      assert :ok = Store.set(custom)
      assert Store.get() == custom
    end

    test "clear/0 removes current theme" do
      Store.set(:nord)
      assert Store.get() != nil
      Store.clear()
      assert Store.get() == nil
    end
  end

  describe "Theme.color/2" do
    test "returns direct palette colors" do
      theme = Palette.get(:nord)
      assert Theme.color(theme, :ansi_1) == theme.ansi_1
      assert Theme.color(theme, :foreground) == theme.foreground
      assert Theme.color(theme, :background) == theme.background
    end

    test "derives semantic colors from ANSI palette" do
      theme = Palette.get(:nord)
      # Semantic colors derive from ANSI
      assert Theme.color(theme, :error) == theme.ansi_1
      assert Theme.color(theme, :success) == theme.ansi_2
      assert Theme.color(theme, :warning) == theme.ansi_3
      assert Theme.color(theme, :emphasis) == theme.ansi_4
      assert Theme.color(theme, :header) == theme.ansi_6
      assert Theme.color(theme, :muted) == theme.ansi_8
    end

    test "returns nil for unknown color name" do
      theme = Palette.get(:nord)
      assert Theme.color(theme, :unknown) == nil
    end
  end

  describe "Esc theme functions" do
    test "set_theme/1 and get_theme/0" do
      assert Esc.get_theme() == nil
      Esc.set_theme(:dracula)
      assert %Theme{name: :dracula} = Esc.get_theme()
    end

    test "clear_theme/0" do
      Esc.set_theme(:nord)
      Esc.clear_theme()
      assert Esc.get_theme() == nil
    end

    test "themes/0 lists all themes" do
      assert Esc.themes() == Palette.list()
    end

    test "theme_color/1 returns color from current theme" do
      Esc.set_theme(:nord)
      assert Esc.theme_color(:error) == {191, 97, 106}
    end

    test "theme_color/1 returns nil when no theme set" do
      assert Esc.theme_color(:error) == nil
    end

    test "theme_foreground/2 applies theme color" do
      Esc.set_theme(:nord)
      style = Esc.style() |> Esc.theme_foreground(:error)
      assert style.foreground == {191, 97, 106}
    end

    test "theme_foreground/2 unchanged when no theme" do
      style = Esc.style() |> Esc.theme_foreground(:error)
      assert style.foreground == nil
    end

    test "theme_background/2 applies theme color" do
      Esc.set_theme(:nord)
      style = Esc.style() |> Esc.theme_background(:success)
      assert style.background == {163, 190, 140}
    end

    test "theme_border_foreground/2 applies theme color" do
      Esc.set_theme(:nord)
      style = Esc.style() |> Esc.theme_border_foreground(:muted)
      assert style.border_foreground == {76, 86, 106}
    end
  end

  describe "themed rendering" do
    test "renders with theme colors" do
      Esc.set_theme(:dracula)
      output = Esc.style() |> Esc.theme_foreground(:error) |> Esc.render("Error!")
      # Should contain ANSI escape codes for the color
      assert String.contains?(output, "\e[38;2;255;85;85m")
      assert String.contains?(output, "Error!")
    end
  end
end
