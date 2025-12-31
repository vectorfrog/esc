defmodule Esc.StyleTest do
  use ExUnit.Case
  import Esc

  describe "inherit/2" do
    test "inherits unset properties from another style" do
      base =
        style()
        |> foreground(:red)
        |> bold()
        |> padding(2)

      derived =
        style()
        |> foreground(:blue)  # Override red
        |> inherit(base)

      # Should have blue foreground (not inherited)
      assert derived.foreground == :blue
      # Should inherit bold
      assert derived.bold == true
      # Should inherit padding
      assert derived.padding_top == 2
    end

    test "does not override already-set properties" do
      base =
        style()
        |> foreground(:red)
        |> background(:white)
        |> border(:rounded)

      derived =
        style()
        |> foreground(:blue)
        |> border(:normal)
        |> inherit(base)

      # These were set, should not be inherited
      assert derived.foreground == :blue
      assert derived.border == :normal
      # This was not set, should be inherited
      assert derived.background == :white
    end

    test "inheritance chain works" do
      grandparent =
        style()
        |> foreground(:red)
        |> bold()

      parent =
        style()
        |> background(:blue)
        |> inherit(grandparent)

      child =
        style()
        |> italic()
        |> inherit(parent)

      assert child.foreground == :red
      assert child.background == :blue
      assert child.bold == true
      assert child.italic == true
    end
  end

  describe "copy/1" do
    test "creates an independent copy of a style" do
      original =
        style()
        |> foreground(:red)
        |> bold()
        |> padding(2)

      copied = Esc.copy(original)

      # Should be equal
      assert copied == original

      # Modifying copy should not affect original
      modified = copied |> foreground(:blue)
      assert original.foreground == :red
      assert modified.foreground == :blue
    end
  end

  describe "unset functions" do
    test "unset_foreground removes foreground color" do
      s =
        style()
        |> foreground(:red)
        |> unset_foreground()

      assert s.foreground == nil
    end

    test "unset_background removes background color" do
      s =
        style()
        |> background(:blue)
        |> unset_background()

      assert s.background == nil
    end

    test "unset_bold disables bold" do
      s =
        style()
        |> bold()
        |> unset_bold()

      assert s.bold == false
    end

    test "unset_italic disables italic" do
      s =
        style()
        |> italic()
        |> unset_italic()

      assert s.italic == false
    end

    test "unset_underline disables underline" do
      s =
        style()
        |> underline()
        |> unset_underline()

      assert s.underline == false
    end

    test "unset_padding removes all padding" do
      s =
        style()
        |> padding(5)
        |> unset_padding()

      assert s.padding_top == 0
      assert s.padding_right == 0
      assert s.padding_bottom == 0
      assert s.padding_left == 0
    end

    test "unset_margin removes all margin" do
      s =
        style()
        |> margin(3)
        |> unset_margin()

      assert s.margin_top == 0
      assert s.margin_right == 0
      assert s.margin_bottom == 0
      assert s.margin_left == 0
    end

    test "unset_border removes border" do
      s =
        style()
        |> border(:rounded)
        |> unset_border()

      assert s.border == nil
    end

    test "unset_width removes width constraint" do
      s =
        style()
        |> width(50)
        |> unset_width()

      assert s.width == nil
    end

    test "unset_height removes height constraint" do
      s =
        style()
        |> height(10)
        |> unset_height()

      assert s.height == nil
    end
  end

  describe "unset integration" do
    test "unset properties are not rendered" do
      result =
        style()
        |> foreground(:red)
        |> bold()
        |> unset_foreground()
        |> render("Text")

      # Should have bold but no red color
      assert result =~ "\e[1m"  # bold
      refute result =~ "\e[31m" # red foreground
    end
  end
end
