defmodule Esc.SelectTest do
  use ExUnit.Case
  alias Esc.Select

  # Clear theme before tests to ensure predictable output
  setup do
    Esc.clear_theme()
    :ok
  end

  describe "new/1" do
    test "creates a select with string items" do
      select = Select.new(["Option 1", "Option 2", "Option 3"])
      assert select.items == ["Option 1", "Option 2", "Option 3"]
    end

    test "creates a select with tuple items" do
      select = Select.new([{"Display", :value}, {"Other", :other}])
      assert select.items == [{"Display", :value}, {"Other", :other}]
    end

    test "creates an empty select" do
      select = Select.new([])
      assert select.items == []
    end

    test "defaults selected_index to 0" do
      select = Select.new(["A", "B"])
      assert select.selected_index == 0
    end

    test "defaults cursor to '> '" do
      select = Select.new(["A"])
      assert select.cursor == "> "
    end
  end

  describe "item/2" do
    test "adds a string item" do
      select =
        Select.new([])
        |> Select.item("First")
        |> Select.item("Second")

      assert select.items == ["First", "Second"]
    end

    test "adds a tuple item" do
      select =
        Select.new([])
        |> Select.item({"Display", :value})

      assert select.items == [{"Display", :value}]
    end
  end

  describe "cursor/2" do
    test "sets custom cursor string" do
      select = Select.new(["A"]) |> Select.cursor("-> ")
      assert select.cursor == "-> "
    end
  end

  describe "cursor_style/2" do
    test "sets cursor style" do
      style = Esc.style() |> Esc.foreground(:cyan)
      select = Select.new(["A"]) |> Select.cursor_style(style)
      assert select.cursor_style == style
    end
  end

  describe "selected_style/2" do
    test "sets selected item style" do
      style = Esc.style() |> Esc.bold()
      select = Select.new(["A"]) |> Select.selected_style(style)
      assert select.selected_style == style
    end
  end

  describe "item_style/2" do
    test "sets non-selected item style" do
      style = Esc.style() |> Esc.faint()
      select = Select.new(["A"]) |> Select.item_style(style)
      assert select.item_style == style
    end
  end

  describe "use_theme/2" do
    test "enables theme" do
      select = Select.new(["A"]) |> Select.use_theme(true)
      assert select.use_theme == true
    end

    test "disables theme" do
      select = Select.new(["A"]) |> Select.use_theme(false)
      assert select.use_theme == false
    end
  end

  describe "render/1" do
    test "renders empty select as empty string" do
      result = Select.new([]) |> Select.render()
      assert result == ""
    end

    test "renders single item with cursor" do
      result = Select.new(["Only item"]) |> Select.render()
      assert result == "> Only item"
    end

    test "renders multiple items with cursor on first" do
      result = Select.new(["A", "B", "C"]) |> Select.render()
      lines = String.split(result, "\n")

      assert length(lines) == 3
      assert Enum.at(lines, 0) == "> A"
      assert Enum.at(lines, 1) == "  B"
      assert Enum.at(lines, 2) == "  C"
    end

    test "renders tuple items using display text" do
      result = Select.new([{"Display", :value}]) |> Select.render()
      assert result == "> Display"
    end

    test "renders custom cursor" do
      result =
        Select.new(["Item"])
        |> Select.cursor("=> ")
        |> Select.render()

      assert result == "=> Item"
    end

    test "applies cursor style" do
      result =
        Select.new(["Item"])
        |> Select.cursor_style(Esc.style() |> Esc.foreground(:cyan))
        |> Select.render()

      # Cursor should have cyan color code
      assert result =~ "\e[36m"
    end

    test "applies selected style" do
      result =
        Select.new(["Item"])
        |> Select.selected_style(Esc.style() |> Esc.bold())
        |> Select.render()

      # Selected item should have bold code
      assert result =~ "\e[1m"
    end

    test "applies item style to non-selected items" do
      result =
        Select.new(["A", "B"])
        |> Select.item_style(Esc.style() |> Esc.faint())
        |> Select.render()

      lines = String.split(result, "\n")
      # Second line (non-selected) should have faint code
      assert Enum.at(lines, 1) =~ "\e[2m"
    end

    test "blank cursor preserves alignment" do
      result = Select.new(["Selected", "Not selected"]) |> Select.render()
      lines = String.split(result, "\n")

      # Both lines should be aligned (same position for text)
      # "> Selected" and "  Not selected" - text starts at position 2
      assert String.at(Enum.at(lines, 0), 0) == ">"
      assert String.at(Enum.at(lines, 1), 0) == " "
      assert String.at(Enum.at(lines, 1), 1) == " "
    end
  end

  describe "run/1 with empty list" do
    test "returns :cancelled for empty select" do
      result = Select.new([]) |> Select.run()
      assert result == :cancelled
    end
  end

  # Note: Interactive run/1 tests would require mocking terminal I/O
  # which is complex. The render/1 tests cover the visual output,
  # and manual testing covers the interaction.
end
