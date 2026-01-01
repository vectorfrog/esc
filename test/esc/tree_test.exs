defmodule Esc.TreeTest do
  use ExUnit.Case
  alias Esc.Tree
  import Esc.Test.RenderHelpers

  # Clear theme before tests to ensure predictable output
  setup do
    Esc.clear_theme()
    :ok
  end

  describe "root/1" do
    test "creates a tree with a root label" do
      tree = Tree.root("Root")
      assert tree.root == "Root"
    end
  end

  describe "new/0" do
    test "creates an empty tree" do
      tree = Tree.new()
      assert tree.root == nil
      assert tree.children == []
    end
  end

  describe "child/2" do
    test "adds a child to the tree" do
      tree =
        Tree.root("Root")
        |> Tree.child("Child 1")
        |> Tree.child("Child 2")

      assert length(tree.children) == 2
    end

    test "supports nested trees as children" do
      subtree =
        Tree.root("Subtree")
        |> Tree.child("Leaf")

      tree =
        Tree.root("Root")
        |> Tree.child(subtree)

      assert length(tree.children) == 1
    end
  end

  describe "enumerator/2" do
    test "default enumerator uses standard characters" do
      result =
        Tree.root("Root")
        |> Tree.child("A")
        |> Tree.child("B")
        |> Tree.enumerator(:default)
        |> Tree.render()

      assert result =~ "├──"
      assert result =~ "└──"
    end

    test "rounded enumerator uses rounded characters" do
      result =
        Tree.root("Root")
        |> Tree.child("A")
        |> Tree.child("B")
        |> Tree.enumerator(:rounded)
        |> Tree.render()

      assert result =~ "├──"
      assert result =~ "╰──"
    end
  end

  describe "root_style/2" do
    test "applies style to root" do
      result =
        Tree.root("Root")
        |> Tree.child("Child")
        |> Tree.root_style(Esc.style() |> Esc.bold())
        |> Tree.render()

      # First line (root) should have bold
      first_line = result |> String.split("\n") |> hd()
      assert first_line =~ "\e[1m"
    end
  end

  describe "item_style/2" do
    test "applies style to children" do
      result =
        Tree.root("Root")
        |> Tree.child("Child")
        |> Tree.item_style(Esc.style() |> Esc.foreground(:cyan))
        |> Tree.render()

      assert result =~ "\e[36m"
    end
  end

  describe "enumerator_style/2" do
    test "applies style to tree connectors" do
      result =
        Tree.root("Root")
        |> Tree.child("Child")
        |> Tree.enumerator_style(Esc.style() |> Esc.foreground(:magenta))
        |> Tree.render()

      assert result =~ "\e[35m"
    end
  end

  describe "render/1" do
    test "renders empty tree" do
      result = Tree.new() |> Tree.render()
      assert result == ""
    end

    test "renders tree with only root" do
      result = Tree.root("Just Root") |> Tree.render()
      assert result == "Just Root"
    end

    test "renders simple tree" do
      result =
        Tree.root("Root")
        |> Tree.child("Child 1")
        |> Tree.child("Child 2")
        |> Tree.render()

      lines = String.split(result, "\n")
      assert length(lines) == 3
      assert Enum.at(lines, 0) =~ "Root"
      assert Enum.at(lines, 1) =~ "Child 1"
      assert Enum.at(lines, 2) =~ "Child 2"
    end

    test "renders nested tree" do
      subtree =
        Tree.root("Subtree")
        |> Tree.child("Leaf 1")
        |> Tree.child("Leaf 2")

      result =
        Tree.root("Root")
        |> Tree.child("Direct Child")
        |> Tree.child(subtree)
        |> Tree.render()

      assert result =~ "Root"
      assert result =~ "Direct Child"
      assert result =~ "Subtree"
      assert result =~ "Leaf 1"
      assert result =~ "Leaf 2"
    end

    test "deeply nested tree" do
      deep =
        Tree.root("Level 3")
        |> Tree.child("Deep Leaf")

      mid =
        Tree.root("Level 2")
        |> Tree.child(deep)

      result =
        Tree.root("Level 1")
        |> Tree.child(mid)
        |> Tree.render()

      lines = String.split(result, "\n")
      # Should have increasing indentation
      assert length(lines) == 4
    end

    test "multiple children with subtrees" do
      sub1 = Tree.root("Sub 1") |> Tree.child("Leaf A")
      sub2 = Tree.root("Sub 2") |> Tree.child("Leaf B")

      result =
        Tree.root("Root")
        |> Tree.child(sub1)
        |> Tree.child(sub2)
        |> Tree.render()

      assert result =~ "Sub 1"
      assert result =~ "Leaf A"
      assert result =~ "Sub 2"
      assert result =~ "Leaf B"
    end
  end

  describe "integration" do
    test "styled tree with nested children" do
      subtree =
        Tree.root("Documents")
        |> Tree.child("report.pdf")
        |> Tree.child("notes.txt")

      result =
        Tree.root("Home")
        |> Tree.child(subtree)
        |> Tree.child("Downloads")
        |> Tree.root_style(Esc.style() |> Esc.bold())
        |> Tree.enumerator_style(Esc.style() |> Esc.foreground(:blue))
        |> Tree.render()

      assert result =~ "Home"
      assert result =~ "Documents"
      assert result =~ "report.pdf"
      assert has_bold?(result)
      assert has_foreground_color?(result, :blue)
    end
  end
end
