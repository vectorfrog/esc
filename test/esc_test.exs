defmodule EscTest do
  use ExUnit.Case
  import Esc

  describe "style/0" do
    test "creates an empty style" do
      assert %Esc.Style{} = style()
    end
  end

  describe "colors" do
    test "foreground sets the foreground color" do
      s = style() |> foreground(:red)
      assert s.foreground == :red
    end

    test "background sets the background color" do
      s = style() |> background(:blue)
      assert s.background == :blue
    end
  end

  describe "text formatting" do
    test "bold enables bold" do
      s = style() |> bold()
      assert s.bold == true
    end

    test "italic enables italic" do
      s = style() |> italic()
      assert s.italic == true
    end

    test "underline enables underline" do
      s = style() |> underline()
      assert s.underline == true
    end
  end

  describe "padding" do
    test "padding/2 sets all sides" do
      s = style() |> padding(2)
      assert s.padding_top == 2
      assert s.padding_right == 2
      assert s.padding_bottom == 2
      assert s.padding_left == 2
    end

    test "padding/3 sets vertical and horizontal" do
      s = style() |> padding(1, 2)
      assert s.padding_top == 1
      assert s.padding_bottom == 1
      assert s.padding_right == 2
      assert s.padding_left == 2
    end
  end

  describe "margin" do
    test "margin/2 sets all sides" do
      s = style() |> margin(3)
      assert s.margin_top == 3
      assert s.margin_right == 3
      assert s.margin_bottom == 3
      assert s.margin_left == 3
    end
  end

  describe "border" do
    test "border sets the border style" do
      s = style() |> border(:rounded)
      assert s.border == :rounded
    end

    test "border_foreground sets border color" do
      s = style() |> border_foreground(:cyan)
      assert s.border_foreground == :cyan
    end
  end

  describe "render/2" do
    test "renders plain text without styles" do
      result = style() |> render("hello")
      assert result == "hello"
    end

    test "renders bold text with ANSI codes" do
      result = style() |> bold() |> render("hello")
      assert result =~ "\e[1m"
      assert result =~ "hello"
      assert result =~ "\e[0m"
    end

    test "renders text with foreground color" do
      result = style() |> foreground(:red) |> render("hello")
      assert result =~ "\e[31m"
    end

    test "renders text with border" do
      result = style() |> border(:normal) |> render("hi")
      assert result =~ "┌"
      assert result =~ "┐"
      assert result =~ "└"
      assert result =~ "┘"
      assert result =~ "hi"
    end

    test "renders text with padding" do
      result = style() |> padding(1) |> render("x")
      lines = String.split(result, "\n")
      assert length(lines) == 3
    end
  end
end
