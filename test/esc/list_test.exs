defmodule Esc.ListTest do
  use ExUnit.Case
  alias Esc.List, as: L

  describe "new/1" do
    test "creates a list with items" do
      list = L.new(["Item 1", "Item 2", "Item 3"])
      assert list.items == ["Item 1", "Item 2", "Item 3"]
    end

    test "creates an empty list" do
      list = L.new([])
      assert list.items == []
    end
  end

  describe "item/2" do
    test "adds an item to the list" do
      list =
        L.new([])
        |> L.item("First")
        |> L.item("Second")

      assert list.items == ["First", "Second"]
    end
  end

  describe "enumerator/2" do
    test "sets bullet enumerator (default)" do
      result =
        L.new(["A", "B"])
        |> L.enumerator(:bullet)
        |> L.render()

      assert result =~ "•"
    end

    test "sets dash enumerator" do
      result =
        L.new(["A", "B"])
        |> L.enumerator(:dash)
        |> L.render()

      assert result =~ "-"
    end

    test "sets arabic enumerator" do
      result =
        L.new(["A", "B", "C"])
        |> L.enumerator(:arabic)
        |> L.render()

      assert result =~ "1."
      assert result =~ "2."
      assert result =~ "3."
    end

    test "sets roman enumerator" do
      result =
        L.new(["A", "B", "C", "D"])
        |> L.enumerator(:roman)
        |> L.render()

      assert result =~ "i."
      assert result =~ "ii."
      assert result =~ "iii."
      assert result =~ "iv."
    end

    test "sets alphabet enumerator" do
      result =
        L.new(["A", "B", "C"])
        |> L.enumerator(:alphabet)
        |> L.render()

      assert result =~ "a."
      assert result =~ "b."
      assert result =~ "c."
    end

    test "sets custom function enumerator" do
      custom = fn idx -> "[#{idx + 1}] " end

      result =
        L.new(["A", "B"])
        |> L.enumerator(custom)
        |> L.render()

      assert result =~ "[1]"
      assert result =~ "[2]"
    end
  end

  describe "enumerator_style/2" do
    test "applies style to enumerator" do
      result =
        L.new(["Item"])
        |> L.enumerator(:bullet)
        |> L.enumerator_style(Esc.style() |> Esc.foreground(:cyan))
        |> L.render()

      # Enumerator should have cyan color
      assert result =~ "\e[36m"
    end
  end

  describe "item_style/2" do
    test "applies style to items" do
      result =
        L.new(["Item"])
        |> L.item_style(Esc.style() |> Esc.bold())
        |> L.render()

      assert result =~ "\e[1m"
    end
  end

  describe "nested lists" do
    test "supports nested lists" do
      nested =
        L.new(["Nested 1", "Nested 2"])
        |> L.enumerator(:dash)

      result =
        L.new(["Parent 1", nested, "Parent 2"])
        |> L.enumerator(:bullet)
        |> L.render()

      assert result =~ "•"
      assert result =~ "Parent 1"
      assert result =~ "-"
      assert result =~ "Nested 1"
      assert result =~ "Parent 2"
    end

    test "nested lists are indented" do
      nested = L.new(["Child"])

      result =
        L.new(["Parent", nested])
        |> L.render()

      lines = String.split(result, "\n")
      parent_line = Enum.find(lines, &String.contains?(&1, "Parent"))
      child_line = Enum.find(lines, &String.contains?(&1, "Child"))

      # Child should have more leading spaces
      parent_indent = String.length(parent_line) - String.length(String.trim_leading(parent_line))
      child_indent = String.length(child_line) - String.length(String.trim_leading(child_line))

      assert child_indent > parent_indent
    end
  end

  describe "render/1" do
    test "renders empty list" do
      result = L.new([]) |> L.render()
      assert result == ""
    end

    test "renders single item" do
      result = L.new(["Only item"]) |> L.render()
      assert result =~ "Only item"
    end

    test "renders multiple items on separate lines" do
      result =
        L.new(["A", "B", "C"])
        |> L.render()

      lines = String.split(result, "\n")
      assert length(lines) == 3
    end
  end

  describe "indent/2" do
    test "sets custom indentation" do
      result =
        L.new(["Item"])
        |> L.indent(4)
        |> L.render()

      assert String.starts_with?(result, "    ")
    end
  end
end
