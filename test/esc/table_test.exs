defmodule Esc.TableTest do
  use ExUnit.Case
  alias Esc.Table
  import Esc.Test.RenderHelpers

  # Clear theme before tests to ensure predictable output
  setup do
    Esc.clear_theme()
    :ok
  end

  describe "new/0" do
    test "creates an empty table" do
      table = Table.new()
      assert table.headers == []
      assert table.rows == []
    end
  end

  describe "headers/2" do
    test "sets table headers" do
      table =
        Table.new()
        |> Table.headers(["Name", "Age", "City"])

      assert table.headers == ["Name", "Age", "City"]
    end
  end

  describe "row/2" do
    test "adds a single row" do
      table =
        Table.new()
        |> Table.row(["Alice", "30", "NYC"])

      assert table.rows == [["Alice", "30", "NYC"]]
    end

    test "adds multiple rows incrementally" do
      table =
        Table.new()
        |> Table.row(["Alice", "30", "NYC"])
        |> Table.row(["Bob", "25", "LA"])

      assert length(table.rows) == 2
    end
  end

  describe "rows/2" do
    test "sets all rows at once" do
      data = [
        ["Alice", "30", "NYC"],
        ["Bob", "25", "LA"],
        ["Carol", "35", "Chicago"]
      ]

      table =
        Table.new()
        |> Table.rows(data)

      assert table.rows == data
    end
  end

  describe "border/2" do
    test "sets the border style" do
      table =
        Table.new()
        |> Table.border(:rounded)

      assert table.border == :rounded
    end
  end

  describe "render/1" do
    test "renders a simple table" do
      result =
        Table.new()
        |> Table.headers(["A", "B"])
        |> Table.row(["1", "2"])
        |> Table.render()

      assert result =~ "A"
      assert result =~ "B"
      assert result =~ "1"
      assert result =~ "2"
    end

    test "renders table with border" do
      result =
        Table.new()
        |> Table.headers(["Name"])
        |> Table.row(["Alice"])
        |> Table.border(:normal)
        |> Table.render()

      assert result =~ "┌"
      assert result =~ "┐"
      assert result =~ "└"
      assert result =~ "┘"
      assert result =~ "│"
    end

    test "renders table with rounded border" do
      result =
        Table.new()
        |> Table.headers(["X"])
        |> Table.row(["Y"])
        |> Table.border(:rounded)
        |> Table.render()

      assert result =~ "╭"
      assert result =~ "╯"
    end

    test "columns are properly aligned" do
      result =
        Table.new()
        |> Table.headers(["Short", "Much Longer Header"])
        |> Table.row(["A", "B"])
        |> Table.border(:normal)
        |> Table.render()

      lines = String.split(result, "\n")
      # All lines should have the same width
      widths = Enum.map(lines, &visible_width/1)
      assert length(Enum.uniq(widths)) == 1
    end

    test "renders table without headers" do
      result =
        Table.new()
        |> Table.row(["A", "B"])
        |> Table.row(["C", "D"])
        |> Table.border(:normal)
        |> Table.render()

      assert result =~ "A"
      assert result =~ "D"
    end

    test "renders empty table" do
      result =
        Table.new()
        |> Table.render()

      assert result == ""
    end
  end

  describe "header_style/2" do
    test "applies style to headers" do
      result =
        Table.new()
        |> Table.headers(["Name"])
        |> Table.row(["Alice"])
        |> Table.header_style(Esc.style() |> Esc.bold())
        |> Table.border(:normal)
        |> Table.render()

      # Header should have bold code
      assert result =~ "\e[1m"
    end
  end

  describe "row_style/2" do
    test "applies style to all rows" do
      result =
        Table.new()
        |> Table.headers(["Name"])
        |> Table.row(["Alice"])
        |> Table.row_style(Esc.style() |> Esc.foreground(:cyan))
        |> Table.border(:normal)
        |> Table.render()

      assert result =~ "\e[36m"
    end
  end

  describe "style_func/2" do
    test "applies per-cell styling" do
      # Alternate row colors
      style_fn = fn row, _col ->
        if rem(row, 2) == 0 do
          Esc.style() |> Esc.foreground(:cyan)
        else
          Esc.style() |> Esc.foreground(:magenta)
        end
      end

      result =
        Table.new()
        |> Table.row(["Row 0"])
        |> Table.row(["Row 1"])
        |> Table.row(["Row 2"])
        |> Table.style_func(style_fn)
        |> Table.border(:normal)
        |> Table.render()

      # Should have both colors
      assert result =~ "\e[36m"  # cyan
      assert result =~ "\e[35m"  # magenta
    end
  end

  describe "width/2" do
    test "sets minimum column widths" do
      result =
        Table.new()
        |> Table.headers(["A"])
        |> Table.row(["X"])
        |> Table.width(0, 20)
        |> Table.border(:normal)
        |> Table.render()

      lines = String.split(result, "\n")
      # Width should be at least 20 + 2 for borders
      assert visible_width(hd(lines)) >= 22
    end
  end
end
