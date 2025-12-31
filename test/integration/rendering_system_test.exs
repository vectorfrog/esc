defmodule Esc.Integration.RenderingSystemTest do
  @moduledoc """
  Integration tests for rendering system enhancements.
  """
  use ExUnit.Case
  import Esc
  import Esc.Test.RenderHelpers

  describe "inline mode" do
    test "inline strips newlines from content" do
      result =
        style()
        |> inline(true)
        |> render("Line 1\nLine 2\nLine 3")

      refute result =~ "\n"
      assert result =~ "Line 1"
      assert result =~ "Line 2"
    end

    test "inline disables width/height constraints" do
      result =
        style()
        |> width(50)
        |> height(10)
        |> inline(true)
        |> render("Short")

      # Should just be the text, no padding to dimensions
      stripped = strip_ansi(result)
      assert stripped == "Short"
    end

    test "inline with styling preserves style codes" do
      result =
        style()
        |> bold()
        |> foreground(:red)
        |> inline(true)
        |> render("A\nB")

      assert has_bold?(result)
      assert has_foreground_color?(result, :red)
      refute result =~ "\n"
    end

    test "inline mode can be toggled" do
      s = style() |> inline(true) |> inline(false)
      result = s |> render("A\nB")
      assert result =~ "\n"
    end
  end

  describe "max_width" do
    test "truncates content that exceeds max_width" do
      result =
        style()
        |> max_width(10)
        |> render("This is a very long line of text")

      assert visible_width(result) <= 10
    end

    test "does not affect content within max_width" do
      result =
        style()
        |> max_width(50)
        |> render("Short text")

      assert strip_ansi(result) == "Short text"
    end

    test "max_width with multiline truncates each line" do
      result =
        style()
        |> max_width(5)
        |> render("AAAAAAAAAA\nBBBBBBBBBB")

      lines = String.split(result, "\n")

      for line <- lines do
        assert visible_width(line) <= 5
      end
    end

    test "max_width works with styled content" do
      result =
        style()
        |> bold()
        |> max_width(5)
        |> render("Long bold text")

      assert visible_width(result) <= 5
      assert has_bold?(result)
    end
  end

  describe "max_height" do
    test "truncates content that exceeds max_height" do
      result =
        style()
        |> max_height(2)
        |> render("Line 1\nLine 2\nLine 3\nLine 4\nLine 5")

      assert visible_height(result) <= 2
    end

    test "does not affect content within max_height" do
      result =
        style()
        |> max_height(10)
        |> render("Line 1\nLine 2")

      assert visible_height(result) == 2
    end

    test "max_height works with styled content" do
      result =
        style()
        |> foreground(:red)
        |> max_height(1)
        |> render("Line 1\nLine 2\nLine 3")

      assert visible_height(result) == 1
      assert has_foreground_color?(result, :red)
    end
  end

  describe "max_width and max_height combined" do
    test "both constraints are applied" do
      result =
        style()
        |> max_width(5)
        |> max_height(2)
        |> render("Long line 1\nLong line 2\nLong line 3\nLong line 4")

      {w, h} = visible_dimensions(result)
      assert w <= 5
      assert h <= 2
    end
  end

  describe "TTY color detection" do
    test "has_dark_background? returns boolean" do
      # This just tests the function exists and returns a boolean
      result = Esc.has_dark_background?()
      assert is_boolean(result)
    end

    test "color_profile returns profile atom" do
      result = Esc.color_profile()
      assert result in [:no_color, :ansi, :ansi256, :true_color]
    end

    test "force_color overrides TTY detection" do
      # Save original
      original = Application.get_env(:esc, :force_color)

      try do
        Application.put_env(:esc, :force_color, true)

        result =
          style()
          |> foreground(:red)
          |> render("Text")

        # Should have color codes even if not TTY
        assert has_foreground_color?(result, :red)
      after
        if original do
          Application.put_env(:esc, :force_color, original)
        else
          Application.delete_env(:esc, :force_color)
        end
      end
    end
  end

  describe "no_color mode" do
    test "no_color strips ANSI codes" do
      result =
        style()
        |> bold()
        |> foreground(:red)
        |> background(:blue)
        |> no_color(true)
        |> render("Plain text")

      assert result == "Plain text"
      assert extract_ansi_codes(result) == []
    end

    test "no_color preserves layout" do
      result =
        style()
        |> foreground(:red)
        |> padding(1)
        |> border(:rounded)
        |> no_color(true)
        |> render("Box")

      # Should still have border characters
      assert result =~ "╭"
      assert result =~ "╯"
      # But no color codes
      assert extract_ansi_codes(result) == []
    end
  end

  describe "custom renderer" do
    test "renderer can be set and used" do
      # Custom renderer that uppercases all text
      upcase_renderer = fn text, _style ->
        text
        |> String.split("\n")
        |> Enum.map(&String.upcase/1)
        |> Enum.join("\n")
      end

      result =
        style()
        |> renderer(upcase_renderer)
        |> render("hello world")

      assert result == "HELLO WORLD"
    end

    test "renderer receives style context" do
      # Renderer that adds prefix based on style
      prefix_renderer = fn text, style ->
        prefix = if style.bold, do: "[B] ", else: ""
        prefix <> text
      end

      result =
        style()
        |> bold()
        |> renderer(prefix_renderer)
        |> render("Content")

      assert result == "[B] Content"
    end
  end
end
