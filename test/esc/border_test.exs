defmodule Esc.BorderTest do
  use ExUnit.Case
  alias Esc.Border

  describe "get/1" do
    test "returns normal border" do
      border = Border.get(:normal)
      assert border.top == "─"
      assert border.bottom == "─"
      assert border.left == "│"
      assert border.right == "│"
      assert border.top_left == "┌"
      assert border.top_right == "┐"
      assert border.bottom_left == "└"
      assert border.bottom_right == "┘"
    end

    test "returns rounded border" do
      border = Border.get(:rounded)
      assert border.top_left == "╭"
      assert border.top_right == "╮"
      assert border.bottom_left == "╰"
      assert border.bottom_right == "╯"
    end

    test "returns thick border" do
      border = Border.get(:thick)
      assert border.top == "━"
      assert border.left == "┃"
      assert border.top_left == "┏"
    end

    test "returns double border" do
      border = Border.get(:double)
      assert border.top == "═"
      assert border.left == "║"
      assert border.top_left == "╔"
    end

    test "returns hidden border (all spaces)" do
      border = Border.get(:hidden)
      assert border.top == " "
      assert border.left == " "
      assert border.top_left == " "
    end

    test "returns markdown border" do
      border = Border.get(:markdown)
      assert border.top == "-"
      assert border.left == "|"
      assert border.top_left == "|"
    end

    test "returns ascii border" do
      border = Border.get(:ascii)
      assert border.top == "-"
      assert border.left == "|"
      assert border.top_left == "+"
      assert border.top_right == "+"
      assert border.bottom_left == "+"
      assert border.bottom_right == "+"
    end

    test "returns nil for unknown style" do
      assert Border.get(:unknown) == nil
    end
  end

  describe "styles/0" do
    test "lists all available styles" do
      styles = Border.styles()
      assert :normal in styles
      assert :rounded in styles
      assert :thick in styles
      assert :double in styles
      assert :hidden in styles
      assert :markdown in styles
      assert :ascii in styles
    end
  end

  describe "custom/1" do
    test "creates a custom border from keyword list" do
      border = Border.custom(
        top: "~",
        bottom: "~",
        left: "!",
        right: "!",
        top_left: "*",
        top_right: "*",
        bottom_left: "*",
        bottom_right: "*"
      )

      assert border.top == "~"
      assert border.left == "!"
      assert border.top_left == "*"
    end

    test "uses defaults for missing characters" do
      border = Border.custom(top: "=")

      assert border.top == "="
      # Defaults to normal border chars
      assert border.left == "│"
      assert border.top_left == "┌"
    end
  end
end
