defmodule Esc.Integration.BorderTest do
  @moduledoc """
  Integration tests for border rendering.
  """
  use ExUnit.Case
  import Esc
  import Esc.Test.RenderHelpers

  describe "per-side border control" do
    test "border with only top enabled" do
      result =
        style()
        |> border(:normal)
        |> border_top(true)
        |> border_bottom(false)
        |> border_left(false)
        |> border_right(false)
        |> render("Content")

      lines = String.split(result, "\n")
      first_line = hd(lines)

      # Top border should exist
      assert first_line =~ "─"
      # No left/right borders
      refute Enum.any?(lines, &String.contains?(&1, "│"))
    end

    test "border with only left and right enabled" do
      result =
        style()
        |> border(:normal)
        |> border_top(false)
        |> border_bottom(false)
        |> border_left(true)
        |> border_right(true)
        |> render("Hi")

      lines = String.split(result, "\n")

      # Should have exactly 1 line (content only, no top/bottom)
      assert length(lines) == 1

      # Line should have left and right borders
      assert hd(lines) =~ "│"
    end

    test "border with all sides enabled (default)" do
      result =
        style()
        |> border(:normal)
        |> render("Box")

      lines = String.split(result, "\n")

      # Should have 3 lines: top, content, bottom
      assert length(lines) == 3
      assert hd(lines) =~ "┌"
      assert List.last(lines) =~ "└"
    end

    test "no borders when all sides disabled" do
      result =
        style()
        |> border(:normal)
        |> border_top(false)
        |> border_bottom(false)
        |> border_left(false)
        |> border_right(false)
        |> render("No border")

      assert result == "No border"
    end
  end

  describe "markdown border style" do
    test "renders markdown table style border" do
      result =
        style()
        |> border(:markdown)
        |> render("Cell")

      assert result =~ "|"
      assert result =~ "-"
    end
  end

  describe "ascii border style" do
    test "renders ASCII art style border" do
      result =
        style()
        |> border(:ascii)
        |> render("Box")

      assert result =~ "+"
      assert result =~ "-"
      assert result =~ "|"
    end

    test "ASCII border has correct corners" do
      result =
        style()
        |> border(:ascii)
        |> render("X")

      lines = String.split(result, "\n")

      # Top line should be +--...--+
      assert hd(lines) =~ ~r/^\+-+\+$/
      # Bottom line should be +--...--+
      assert List.last(lines) =~ ~r/^\+-+\+$/
    end
  end

  describe "custom borders" do
    test "renders with custom border characters" do
      result =
        style()
        |> custom_border(
          top: "=",
          bottom: "=",
          left: "H",
          right: "H",
          top_left: "#",
          top_right: "#",
          bottom_left: "#",
          bottom_right: "#"
        )
        |> render("Custom")

      assert result =~ "#"
      assert result =~ "="
      assert result =~ "H"
    end

    test "custom border with emoji" do
      result =
        style()
        |> custom_border(
          top: "~",
          bottom: "~",
          left: "|",
          right: "|",
          top_left: "o",
          top_right: "o",
          bottom_left: "o",
          bottom_right: "o"
        )
        |> render("Hi")

      assert result =~ "o"
      assert result =~ "~"
    end
  end

  describe "border with content" do
    test "multiline content with border" do
      result =
        style()
        |> border(:rounded)
        |> render("Line 1\nLine 2\nLine 3")

      lines = String.split(result, "\n")

      # 5 lines: top border + 3 content + bottom border
      assert length(lines) == 5

      # All middle lines should have side borders
      middle = Enum.slice(lines, 1, 3)

      for line <- middle do
        stripped = strip_ansi(line)
        assert String.starts_with?(stripped, "│")
        assert String.ends_with?(stripped, "│")
      end
    end

    test "border with padding" do
      result =
        style()
        |> border(:normal)
        |> padding(1)
        |> render("X")

      lines = String.split(result, "\n")

      # top border + 1 padding + content + 1 padding + bottom border = 5
      assert length(lines) == 5
    end

    test "border with fixed width" do
      result =
        style()
        |> border(:normal)
        |> width(20)
        |> render("Hi")

      lines = String.split(result, "\n")

      # All lines should be same width
      widths = Enum.map(lines, &visible_width/1)
      assert Enum.uniq(widths) == [22]  # 20 + 2 for borders
    end
  end
end
