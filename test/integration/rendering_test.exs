defmodule Esc.Integration.RenderingTest do
  @moduledoc """
  Integration tests that verify complete rendering pipelines.
  These tests ensure that combinations of styles work together correctly.
  """
  use ExUnit.Case
  import Esc
  import Esc.Test.RenderHelpers

  describe "Lipgloss canonical example" do
    test "renders styled box matching Lipgloss output" do
      # The canonical Lipgloss example:
      # lipgloss.NewStyle().
      #   Bold(true).
      #   Foreground(lipgloss.Color("#FAFAFA")).
      #   Background(lipgloss.Color("#7D56F4")).
      #   PaddingTop(2).
      #   PaddingLeft(4).
      #   Width(22)
      result =
        style()
        |> bold()
        |> foreground("#FAFAFA")
        |> background("#7D56F4")
        |> padding(2, 4, 2, 4)
        |> width(22)
        |> render("Hello, kitty")

      # Verify styling
      assert has_bold?(result)
      assert has_foreground_color?(result, {250, 250, 250})
      assert has_background_color?(result, {125, 86, 244})

      # Verify dimensions (width: 22, height: content + padding)
      {w, h} = visible_dimensions(result)
      assert w == 22
      # 2 top padding + 1 content + 2 bottom padding = 5 lines
      assert h == 5
    end

    test "renders simple colored text" do
      result =
        style()
        |> foreground(:red)
        |> render("Error!")

      assert has_foreground_color?(result, :red)
      assert strip_ansi(result) == "Error!"
    end

    test "renders text with border and padding" do
      result =
        style()
        |> border(:rounded)
        |> padding(1, 2)
        |> render("Box")

      # Should have rounded corners
      assert result =~ "╭"
      assert result =~ "╮"
      assert result =~ "╰"
      assert result =~ "╯"

      # Content should be padded
      lines = String.split(result, "\n")
      # top border, padding, content, padding, bottom border
      assert length(lines) == 5
    end
  end

  describe "color combinations" do
    test "foreground and background together" do
      result =
        style()
        |> foreground(:white)
        |> background(:blue)
        |> render("Info")

      assert has_foreground_color?(result, :white)
      assert has_background_color?(result, :blue)
    end

    test "256 color palette" do
      result =
        style()
        |> foreground(196)
        |> background(21)
        |> render("Bright")

      assert has_foreground_color?(result, 196)
      assert has_background_color?(result, 21)
    end

    test "true color RGB" do
      result =
        style()
        |> foreground({255, 128, 0})
        |> background({0, 0, 128})
        |> render("Orange on Navy")

      assert has_foreground_color?(result, {255, 128, 0})
      assert has_background_color?(result, {0, 0, 128})
    end

    test "hex color strings" do
      result =
        style()
        |> foreground("#ff8000")
        |> background("#000080")
        |> render("Hex colors")

      # Hex should convert to RGB
      assert has_foreground_color?(result, {255, 128, 0})
      assert has_background_color?(result, {0, 0, 128})
    end
  end

  describe "text formatting combinations" do
    test "bold and italic together" do
      result =
        style()
        |> bold()
        |> italic()
        |> render("Emphasis")

      assert has_bold?(result)
      assert has_italic?(result)
    end

    test "all text styles" do
      result =
        style()
        |> bold()
        |> italic()
        |> underline()
        |> render("All styles")

      assert has_bold?(result)
      assert has_italic?(result)
      assert has_underline?(result)
    end

    test "text styles with colors" do
      result =
        style()
        |> bold()
        |> foreground(:red)
        |> background(:white)
        |> render("Warning")

      assert has_bold?(result)
      assert has_foreground_color?(result, :red)
      assert has_background_color?(result, :white)
    end
  end

  describe "layout combinations" do
    test "padding with fixed width" do
      result =
        style()
        |> padding(0, 2)
        |> width(20)
        |> render("Padded")

      {w, _h} = visible_dimensions(result)
      assert w == 20

      # Content should have padding on left and right
      stripped = strip_ansi(result)
      assert String.starts_with?(stripped, "  ")
    end

    test "margin with border" do
      result =
        style()
        |> margin(1, 2)
        |> border(:normal)
        |> render("Margined")

      lines = String.split(result, "\n")

      # First line should be empty (top margin)
      assert hd(lines) == ""

      # Second line should start with margin spaces then border
      second = Enum.at(lines, 1)
      assert String.starts_with?(second, "  ")
      assert second =~ "┌"
    end

    test "centered text in fixed width" do
      result =
        style()
        |> width(20)
        |> align(:center)
        |> render("Hi")

      stripped = strip_ansi(result)
      assert String.length(stripped) == 20

      # "Hi" is 2 chars, so 9 spaces on left, 9 on right
      trimmed = String.trim(stripped)
      assert trimmed == "Hi"

      left_spaces = String.length(stripped) - String.length(String.trim_leading(stripped))
      assert left_spaces == 9
    end

    test "right-aligned text" do
      result =
        style()
        |> width(10)
        |> align(:right)
        |> render("Hi")

      stripped = strip_ansi(result)
      assert String.length(stripped) == 10
      assert String.ends_with?(stripped, "Hi")
    end
  end

  describe "border combinations" do
    test "border with foreground color" do
      result =
        style()
        |> border(:rounded)
        |> border_foreground(:cyan)
        |> render("Colored border")

      assert result =~ "╭"
      assert has_foreground_color?(result, :cyan)
    end

    test "border with different content color" do
      result =
        style()
        |> border(:normal)
        |> border_foreground(:blue)
        |> foreground(:red)
        |> render("Red text, blue border")

      assert has_foreground_color?(result, :blue)
      assert has_foreground_color?(result, :red)
    end

    test "all border styles render correctly" do
      for {style_name, corners} <- [
            {:normal, {"┌", "┐", "└", "┘"}},
            {:rounded, {"╭", "╮", "╰", "╯"}},
            {:thick, {"┏", "┓", "┗", "┛"}},
            {:double, {"╔", "╗", "╚", "╝"}},
            {:hidden, {" ", " ", " ", " "}}
          ] do
        result = style() |> border(style_name) |> render("X")
        {tl, tr, bl, br} = corners
        assert result =~ tl, "#{style_name} missing top-left"
        assert result =~ tr, "#{style_name} missing top-right"
        assert result =~ bl, "#{style_name} missing bottom-left"
        assert result =~ br, "#{style_name} missing bottom-right"
      end
    end
  end

  describe "multiline content" do
    test "renders multiline text with border" do
      result =
        style()
        |> border(:normal)
        |> render("Line 1\nLine 2\nLine 3")

      lines = String.split(result, "\n")
      # border top + 3 content lines + border bottom = 5
      assert length(lines) == 5

      # All content lines should have borders
      middle_lines = Enum.slice(lines, 1, 3)

      for line <- middle_lines do
        assert line =~ "│"
      end
    end

    test "multiline with padding" do
      result =
        style()
        |> padding(1)
        |> render("A\nB")

      lines = String.split(result, "\n")
      # 1 top padding + 2 content + 1 bottom padding = 4
      assert length(lines) == 4
    end

    test "multiline with fixed width aligns all lines" do
      result =
        style()
        |> width(10)
        |> align(:right)
        |> render("A\nBB\nCCC")

      lines = String.split(result, "\n")

      for line <- lines do
        assert visible_width(line) == 10
      end

      # Each line should be right-aligned
      assert strip_ansi(Enum.at(lines, 0)) |> String.ends_with?("A")
      assert strip_ansi(Enum.at(lines, 1)) |> String.ends_with?("BB")
      assert strip_ansi(Enum.at(lines, 2)) |> String.ends_with?("CCC")
    end
  end

  describe "edge cases" do
    test "empty string renders correctly" do
      result = style() |> render("")
      assert result == ""
    end

    test "empty string with padding" do
      result = style() |> padding(1) |> render("")

      lines = String.split(result, "\n")
      # padding creates 3 lines even with empty content
      assert length(lines) == 3
    end

    test "empty string with border" do
      result = style() |> border(:normal) |> render("")

      assert result =~ "┌"
      assert result =~ "└"
    end

    test "very long text with fixed width truncates" do
      result =
        style()
        |> width(5)
        |> render("Hello, World!")

      {w, _h} = visible_dimensions(result)
      assert w == 5
    end

    test "unicode content" do
      result =
        style()
        |> border(:rounded)
        |> render("Hello 世界")

      assert result =~ "Hello 世界"
      assert result =~ "╭"
    end

    test "emoji content" do
      result =
        style()
        |> foreground(:yellow)
        |> render("Star: ⭐")

      assert strip_ansi(result) =~ "⭐"
    end
  end

  describe "reset codes" do
    test "each styled line ends with reset" do
      result =
        style()
        |> bold()
        |> foreground(:red)
        |> render("Line 1\nLine 2")

      lines = String.split(result, "\n")

      for line <- lines do
        assert has_reset?(line), "Line should end with reset: #{inspect(line)}"
      end
    end

    test "unstyled content has no ANSI codes" do
      result = style() |> render("Plain text")

      assert result == "Plain text"
      assert extract_ansi_codes(result) == []
    end
  end
end
