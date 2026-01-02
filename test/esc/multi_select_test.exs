defmodule Esc.MultiSelectTest do
  use ExUnit.Case
  alias Esc.MultiSelect

  # Clear theme before tests to ensure predictable output
  setup do
    Esc.clear_theme()
    :ok
  end

  describe "new/1" do
    test "creates a multi-select with string items" do
      ms = MultiSelect.new(["Option 1", "Option 2", "Option 3"])
      assert ms.items == ["Option 1", "Option 2", "Option 3"]
    end

    test "creates a multi-select with tuple items" do
      ms = MultiSelect.new([{"Display", :value}, {"Other", :other}])
      assert ms.items == [{"Display", :value}, {"Other", :other}]
    end

    test "creates an empty multi-select" do
      ms = MultiSelect.new([])
      assert ms.items == []
    end

    test "defaults cursor_index to 0" do
      ms = MultiSelect.new(["A", "B"])
      assert ms.cursor_index == 0
    end

    test "defaults selected_indices to empty MapSet" do
      ms = MultiSelect.new(["A", "B"])
      assert ms.selected_indices == MapSet.new()
    end

    test "defaults cursor to '> '" do
      ms = MultiSelect.new(["A"])
      assert ms.cursor == "> "
    end

    test "defaults markers to checkbox style" do
      ms = MultiSelect.new(["A"])
      assert ms.selected_marker == "[x] "
      assert ms.unselected_marker == "[ ] "
    end
  end

  describe "item/2" do
    test "adds a string item" do
      ms =
        MultiSelect.new([])
        |> MultiSelect.item("First")
        |> MultiSelect.item("Second")

      assert ms.items == ["First", "Second"]
    end

    test "adds a tuple item" do
      ms =
        MultiSelect.new([])
        |> MultiSelect.item({"Display", :value})

      assert ms.items == [{"Display", :value}]
    end
  end

  describe "preselect/2" do
    test "preselects items by index" do
      ms =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.preselect([0, 2])

      assert MapSet.member?(ms.selected_indices, 0)
      assert MapSet.member?(ms.selected_indices, 2)
      refute MapSet.member?(ms.selected_indices, 1)
    end

    test "preselects items by value" do
      ms =
        MultiSelect.new([{"A", :a}, {"B", :b}, {"C", :c}])
        |> MultiSelect.preselect([:a, :c])

      assert MapSet.member?(ms.selected_indices, 0)
      assert MapSet.member?(ms.selected_indices, 2)
      refute MapSet.member?(ms.selected_indices, 1)
    end

    test "ignores out of range indices" do
      ms =
        MultiSelect.new(["A", "B"])
        |> MultiSelect.preselect([0, 5, 10])

      assert MapSet.size(ms.selected_indices) == 1
      assert MapSet.member?(ms.selected_indices, 0)
    end

    test "ignores non-existent values" do
      ms =
        MultiSelect.new([{"A", :a}, {"B", :b}])
        |> MultiSelect.preselect([:a, :not_found])

      assert MapSet.size(ms.selected_indices) == 1
      assert MapSet.member?(ms.selected_indices, 0)
    end
  end

  describe "cursor/2" do
    test "sets custom cursor string" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.cursor("-> ")
      assert ms.cursor == "-> "
    end
  end

  describe "cursor_style/2" do
    test "sets cursor style" do
      style = Esc.style() |> Esc.foreground(:cyan)
      ms = MultiSelect.new(["A"]) |> MultiSelect.cursor_style(style)
      assert ms.cursor_style == style
    end
  end

  describe "markers/3" do
    test "sets both markers" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.markers("* ", "  ")
      assert ms.selected_marker == "* "
      assert ms.unselected_marker == "  "
    end
  end

  describe "selected_marker/2" do
    test "sets selected marker" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.selected_marker("[*] ")
      assert ms.selected_marker == "[*] "
    end
  end

  describe "unselected_marker/2" do
    test "sets unselected marker" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.unselected_marker("[ ] ")
      assert ms.unselected_marker == "[ ] "
    end
  end

  describe "marker_styles/3" do
    test "sets both marker styles" do
      selected_style = Esc.style() |> Esc.foreground(:green)
      unselected_style = Esc.style() |> Esc.foreground(:gray)

      ms =
        MultiSelect.new(["A"])
        |> MultiSelect.marker_styles(selected_style, unselected_style)

      assert ms.selected_marker_style == selected_style
      assert ms.unselected_marker_style == unselected_style
    end
  end

  describe "focused_style/2" do
    test "sets focused item style" do
      style = Esc.style() |> Esc.bold()
      ms = MultiSelect.new(["A"]) |> MultiSelect.focused_style(style)
      assert ms.focused_style == style
    end
  end

  describe "item_style/2" do
    test "sets non-focused item style" do
      style = Esc.style() |> Esc.faint()
      ms = MultiSelect.new(["A"]) |> MultiSelect.item_style(style)
      assert ms.item_style == style
    end
  end

  describe "selected_item_style/2" do
    test "sets selected item style" do
      style = Esc.style() |> Esc.foreground(:green)
      ms = MultiSelect.new(["A"]) |> MultiSelect.selected_item_style(style)
      assert ms.selected_item_style == style
    end
  end

  describe "min_selections/2" do
    test "sets minimum selections" do
      ms = MultiSelect.new(["A", "B"]) |> MultiSelect.min_selections(1)
      assert ms.min_selections == 1
    end
  end

  describe "max_selections/2" do
    test "sets maximum selections" do
      ms = MultiSelect.new(["A", "B", "C"]) |> MultiSelect.max_selections(2)
      assert ms.max_selections == 2
    end

    test "allows nil for unlimited" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.max_selections(nil)
      assert ms.max_selections == nil
    end
  end

  describe "show_help/2" do
    test "enables help text" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.show_help(true)
      assert ms.show_help == true
    end

    test "disables help text" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.show_help(false)
      assert ms.show_help == false
    end
  end

  describe "help_style/2" do
    test "sets help text style" do
      style = Esc.style() |> Esc.faint()
      ms = MultiSelect.new(["A"]) |> MultiSelect.help_style(style)
      assert ms.help_style == style
    end
  end

  describe "use_theme/2" do
    test "enables theme" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.use_theme(true)
      assert ms.use_theme == true
    end

    test "disables theme" do
      ms = MultiSelect.new(["A"]) |> MultiSelect.use_theme(false)
      assert ms.use_theme == false
    end
  end

  describe "render/1" do
    test "renders empty multi-select as empty string" do
      result = MultiSelect.new([]) |> MultiSelect.render()
      assert result == ""
    end

    test "renders single item with cursor and marker" do
      result =
        MultiSelect.new(["Only item"])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      assert result == "> [ ] Only item"
    end

    test "renders multiple items with cursor on first" do
      result =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      lines = String.split(result, "\n")

      assert length(lines) == 3
      assert Enum.at(lines, 0) == "> [ ] A"
      assert Enum.at(lines, 1) == "  [ ] B"
      assert Enum.at(lines, 2) == "  [ ] C"
    end

    test "renders selected items with selected marker" do
      result =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.preselect([1])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      lines = String.split(result, "\n")

      assert Enum.at(lines, 0) == "> [ ] A"
      assert Enum.at(lines, 1) == "  [x] B"
      assert Enum.at(lines, 2) == "  [ ] C"
    end

    test "renders tuple items using display text" do
      result =
        MultiSelect.new([{"Display", :value}])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      assert result == "> [ ] Display"
    end

    test "renders custom cursor" do
      result =
        MultiSelect.new(["Item"])
        |> MultiSelect.cursor("=> ")
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      assert result == "=> [ ] Item"
    end

    test "renders custom markers" do
      result =
        MultiSelect.new(["A", "B"])
        |> MultiSelect.markers("* ", "  ")
        |> MultiSelect.preselect([0])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      lines = String.split(result, "\n")

      assert Enum.at(lines, 0) == "> * A"
      assert Enum.at(lines, 1) == "    B"
    end

    test "renders help text by default" do
      result =
        MultiSelect.new(["A"])
        |> MultiSelect.render()

      assert result =~ "space: toggle"
      assert result =~ "enter: confirm"
      assert result =~ "q: cancel"
    end

    test "hides help text when disabled" do
      result =
        MultiSelect.new(["A"])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      refute result =~ "space: toggle"
    end

    test "help text shows selection count" do
      result =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.preselect([0, 1])
        |> MultiSelect.render()

      assert result =~ "2 selected"
    end

    test "help text shows needed count when below minimum" do
      result =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.min_selections(2)
        |> MultiSelect.render()

      assert result =~ "2 more needed"
    end

    test "help text shows max reached when at maximum" do
      result =
        MultiSelect.new(["A", "B", "C"])
        |> MultiSelect.max_selections(2)
        |> MultiSelect.preselect([0, 1])
        |> MultiSelect.render()

      assert result =~ "max reached"
    end

    test "applies cursor style" do
      result =
        MultiSelect.new(["Item"])
        |> MultiSelect.cursor_style(Esc.style() |> Esc.foreground(:cyan))
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      # Cursor should have cyan color code
      assert result =~ "\e[36m"
    end

    test "applies focused style" do
      result =
        MultiSelect.new(["Item"])
        |> MultiSelect.focused_style(Esc.style() |> Esc.bold())
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      # Focused item should have bold code
      assert result =~ "\e[1m"
    end

    test "applies selected marker style" do
      result =
        MultiSelect.new(["A", "B"])
        |> MultiSelect.marker_styles(Esc.style() |> Esc.foreground(:green), nil)
        |> MultiSelect.preselect([1])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      # Selected marker should have green color code
      assert result =~ "\e[32m"
    end

    test "blank cursor preserves alignment" do
      result =
        MultiSelect.new(["Selected", "Not selected"])
        |> MultiSelect.show_help(false)
        |> MultiSelect.render()

      lines = String.split(result, "\n")

      # Both lines should be aligned
      assert String.at(Enum.at(lines, 0), 0) == ">"
      assert String.at(Enum.at(lines, 1), 0) == " "
      assert String.at(Enum.at(lines, 1), 1) == " "
    end
  end

  describe "run/1 with empty list" do
    test "returns :cancelled for empty multi-select" do
      result = MultiSelect.new([]) |> MultiSelect.run()
      assert result == :cancelled
    end
  end

  # Note: Interactive run/1 tests would require mocking terminal I/O
  # which is complex. The render/1 tests cover the visual output,
  # and manual testing covers the interaction.
end
