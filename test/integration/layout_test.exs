defmodule Esc.Integration.LayoutTest do
  @moduledoc """
  Integration tests for layout and composition features.
  """
  use ExUnit.Case
  import Esc
  import Esc.Test.RenderHelpers

  describe "text measurement" do
    test "get_width returns visible width of plain text" do
      assert Esc.get_width("Hello") == 5
      assert Esc.get_width("Hello, World!") == 13
    end

    test "get_width ignores ANSI codes" do
      styled = style() |> bold() |> foreground(:red) |> render("Hello")
      assert Esc.get_width(styled) == 5
    end

    test "get_width returns max width for multiline" do
      text = "Short\nMuch longer line\nMed"
      assert Esc.get_width(text) == 16
    end

    test "get_height returns line count" do
      assert Esc.get_height("Single") == 1
      assert Esc.get_height("Line 1\nLine 2") == 2
      assert Esc.get_height("A\nB\nC\nD") == 4
    end

    test "get_height works with styled content" do
      styled =
        style()
        |> border(:rounded)
        |> padding(1)
        |> render("X")

      # padding top + content + padding bottom + top border + bottom border
      assert Esc.get_height(styled) == 5
    end
  end

  describe "horizontal joining" do
    test "join_horizontal combines blocks side by side" do
      left = "A\nB\nC"
      right = "1\n2\n3"

      result = Esc.join_horizontal([left, right])

      lines = String.split(result, "\n")
      assert length(lines) == 3
      assert Enum.at(lines, 0) =~ "A"
      assert Enum.at(lines, 0) =~ "1"
    end

    test "join_horizontal with left alignment" do
      short = "X"
      tall = "A\nB\nC"

      result = Esc.join_horizontal([short, tall], :top)

      lines = String.split(result, "\n")
      # First line should have both
      assert Enum.at(lines, 0) =~ "X"
      assert Enum.at(lines, 0) =~ "A"
    end

    test "join_horizontal with center alignment" do
      short = "X"
      tall = "A\nB\nC"

      result = Esc.join_horizontal([short, tall], :middle)

      lines = String.split(result, "\n")
      # X should be on the middle line (line 1, index 1)
      assert Enum.at(lines, 1) =~ "X"
    end

    test "join_horizontal with bottom alignment" do
      short = "X"
      tall = "A\nB\nC"

      result = Esc.join_horizontal([short, tall], :bottom)

      lines = String.split(result, "\n")
      # X should be on the last line
      assert Enum.at(lines, 2) =~ "X"
    end

    test "join_horizontal with styled blocks" do
      left =
        style()
        |> border(:rounded)
        |> render("Left")

      right =
        style()
        |> border(:rounded)
        |> render("Right")

      result = Esc.join_horizontal([left, right])

      # Should have two bordered boxes side by side
      assert result =~ "╭"
      assert result =~ "Left"
      assert result =~ "Right"
    end
  end

  describe "vertical joining" do
    test "join_vertical stacks blocks vertically" do
      top = "AAA"
      bottom = "BBB"

      result = Esc.join_vertical([top, bottom])

      lines = String.split(result, "\n")
      assert length(lines) == 2
      assert Enum.at(lines, 0) == "AAA"
      assert Enum.at(lines, 1) == "BBB"
    end

    test "join_vertical with left alignment" do
      wide = "WIDE"
      narrow = "X"

      result = Esc.join_vertical([wide, narrow], :left)

      lines = String.split(result, "\n")
      # Narrow should be left-aligned (start with X)
      assert String.starts_with?(Enum.at(lines, 1), "X")
    end

    test "join_vertical with center alignment" do
      wide = "WIDE"
      narrow = "X"

      result = Esc.join_vertical([wide, narrow], :center)

      lines = String.split(result, "\n")
      narrow_line = Enum.at(lines, 1)
      # X should be centered (has leading space)
      assert String.trim_leading(narrow_line) == "X   " or String.contains?(narrow_line, " X")
    end

    test "join_vertical with right alignment" do
      wide = "WIDE"
      narrow = "X"

      result = Esc.join_vertical([wide, narrow], :right)

      lines = String.split(result, "\n")
      # Narrow should be right-aligned (end with X)
      assert String.ends_with?(String.trim_trailing(Enum.at(lines, 1)), "X")
    end
  end

  describe "placement" do
    test "place positions text in a box" do
      result = Esc.place(10, 5, :center, :middle, "X")

      {w, h} = visible_dimensions(result)
      assert w == 10
      assert h == 5

      # X should be roughly centered
      lines = String.split(result, "\n")
      middle_line = Enum.at(lines, 2)
      assert middle_line =~ "X"
    end

    test "place_horizontal positions text horizontally" do
      result = Esc.place_horizontal(20, :center, "Hi")

      assert visible_width(result) == 20
      stripped = strip_ansi(result)
      # Should have leading spaces for centering
      assert String.trim(stripped) == "Hi"
      left_spaces = String.length(stripped) - String.length(String.trim_leading(stripped))
      assert left_spaces == 9  # (20 - 2) / 2
    end

    test "place_vertical positions text vertically" do
      result = Esc.place_vertical(5, :middle, "X")

      lines = String.split(result, "\n")
      assert length(lines) == 5

      # X should be on middle line
      middle_line = Enum.at(lines, 2)
      assert String.trim(middle_line) == "X"
    end

    test "place with styled content" do
      styled = style() |> foreground(:red) |> render("Red")
      result = Esc.place(10, 3, :center, :middle, styled)

      {w, h} = visible_dimensions(result)
      assert w == 10
      assert h == 3
    end
  end

  describe "tab handling" do
    test "tabs are expanded to spaces by default" do
      result = style() |> render("A\tB")
      refute result =~ "\t"
      # Default tab width is 4
      assert result =~ "A    B" or result =~ "A   B"
    end

    test "custom tab width" do
      result =
        style()
        |> tab_width(2)
        |> render("A\tB")

      refute result =~ "\t"
      assert result =~ "A  B"
    end

    test "tab_width 0 preserves tabs" do
      result =
        style()
        |> tab_width(0)
        |> render("A\tB")

      assert result =~ "\t"
    end
  end
end
