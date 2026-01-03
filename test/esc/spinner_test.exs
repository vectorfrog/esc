defmodule Esc.SpinnerTest do
  use ExUnit.Case
  alias Esc.Spinner

  # Clear theme before tests to ensure predictable output
  setup do
    Esc.clear_theme()
    :ok
  end

  describe "new/0" do
    test "creates a spinner with default style :dots" do
      spinner = Spinner.new()
      assert spinner.style == :dots
    end

    test "defaults text to empty string" do
      spinner = Spinner.new()
      assert spinner.text == ""
    end

    test "defaults text_position to :right" do
      spinner = Spinner.new()
      assert spinner.text_position == :right
    end

    test "defaults frame_rate to 80" do
      spinner = Spinner.new()
      assert spinner.frame_rate == 80
    end

    test "defaults use_theme to true" do
      spinner = Spinner.new()
      assert spinner.use_theme == true
    end
  end

  describe "new/1 with atom style" do
    test "creates spinner with built-in style" do
      spinner = Spinner.new(:arrows)
      assert spinner.style == :arrows
    end

    test "raises for unknown style" do
      assert_raise ArgumentError, ~r/unknown spinner style/, fn ->
        Spinner.new(:nonexistent)
      end
    end
  end

  describe "new/1 with custom frames" do
    test "creates spinner with custom frames list" do
      frames = [".", "..", "..."]
      spinner = Spinner.new(frames)
      assert spinner.style == frames
    end

    test "raises for empty frames list" do
      assert_raise ArgumentError, ~r/cannot be empty/, fn ->
        Spinner.new([])
      end
    end
  end

  describe "styles/0" do
    test "returns list of available style atoms" do
      styles = Spinner.styles()
      assert is_list(styles)
      assert :dots in styles
      assert :arrows in styles
      assert :circle in styles
    end
  end

  describe "style/2" do
    test "sets built-in style" do
      spinner = Spinner.new() |> Spinner.style(:circle)
      assert spinner.style == :circle
    end

    test "sets custom frames" do
      frames = ["⣾", "⣽", "⣻", "⢿"]
      spinner = Spinner.new() |> Spinner.style(frames)
      assert spinner.style == frames
    end

    test "raises for unknown style" do
      assert_raise ArgumentError, ~r/unknown spinner style/, fn ->
        Spinner.new() |> Spinner.style(:bad_style)
      end
    end

    test "raises for empty frames list" do
      assert_raise ArgumentError, ~r/cannot be empty/, fn ->
        Spinner.new() |> Spinner.style([])
      end
    end
  end

  describe "text/2" do
    test "sets text" do
      spinner = Spinner.new() |> Spinner.text("Loading...")
      assert spinner.text == "Loading..."
    end
  end

  describe "text_position/2" do
    test "sets position to :left" do
      spinner = Spinner.new() |> Spinner.text_position(:left)
      assert spinner.text_position == :left
    end

    test "sets position to :right" do
      spinner = Spinner.new() |> Spinner.text_position(:right)
      assert spinner.text_position == :right
    end
  end

  describe "text_style/2" do
    test "sets text style" do
      style = Esc.style() |> Esc.foreground(:white)
      spinner = Spinner.new() |> Spinner.text_style(style)
      assert spinner.text_style == style
    end
  end

  describe "spinner_style/2" do
    test "sets spinner style" do
      style = Esc.style() |> Esc.foreground(:cyan) |> Esc.bold()
      spinner = Spinner.new() |> Spinner.spinner_style(style)
      assert spinner.spinner_style == style
    end
  end

  describe "frame_rate/2" do
    test "sets frame rate" do
      spinner = Spinner.new() |> Spinner.frame_rate(100)
      assert spinner.frame_rate == 100
    end

    test "raises for non-positive integer" do
      assert_raise ArgumentError, ~r/must be a positive integer/, fn ->
        Spinner.new() |> Spinner.frame_rate(0)
      end
    end

    test "raises for negative integer" do
      assert_raise ArgumentError, ~r/must be a positive integer/, fn ->
        Spinner.new() |> Spinner.frame_rate(-50)
      end
    end
  end

  describe "use_theme/2" do
    test "enables theme" do
      spinner = Spinner.new() |> Spinner.use_theme(true)
      assert spinner.use_theme == true
    end

    test "disables theme" do
      spinner = Spinner.new() |> Spinner.use_theme(false)
      assert spinner.use_theme == false
    end
  end

  describe "render/1" do
    test "renders first frame of dots spinner" do
      result = Spinner.new(:dots) |> Spinner.render()
      assert result == "⠋"
    end

    test "renders first frame of line spinner" do
      result = Spinner.new(:line) |> Spinner.render()
      assert result == "-"
    end

    test "renders spinner with text on right" do
      result =
        Spinner.new(:dots)
        |> Spinner.text("Loading")
        |> Spinner.render()

      assert result == "⠋ Loading"
    end

    test "renders spinner with text on left" do
      result =
        Spinner.new(:dots)
        |> Spinner.text("Loading")
        |> Spinner.text_position(:left)
        |> Spinner.render()

      assert result == "Loading ⠋"
    end

    test "renders custom frames" do
      result = Spinner.new(["A", "B", "C"]) |> Spinner.render()
      assert result == "A"
    end
  end

  describe "render/2" do
    test "renders specific frame by index" do
      spinner = Spinner.new(:dots)

      assert Spinner.render(spinner, 0) == "⠋"
      assert Spinner.render(spinner, 1) == "⠙"
      assert Spinner.render(spinner, 2) == "⠹"
    end

    test "wraps frame index" do
      # :dots has 10 frames, so index 10 should wrap to 0
      spinner = Spinner.new(:dots)
      assert Spinner.render(spinner, 10) == Spinner.render(spinner, 0)
    end

    test "applies spinner style" do
      result =
        Spinner.new(:dots)
        |> Spinner.spinner_style(Esc.style() |> Esc.foreground(:cyan))
        |> Spinner.render()

      # Should contain cyan ANSI code (basic or 256-color)
      assert result =~ "\e[36m" or result =~ "\e[38;5;6m"
    end

    test "applies text style" do
      result =
        Spinner.new(:dots)
        |> Spinner.text("Loading")
        |> Spinner.text_style(Esc.style() |> Esc.bold())
        |> Spinner.render()

      # Should contain bold ANSI code
      assert result =~ "\e[1m"
    end
  end

  describe "run/2" do
    test "executes function and returns result" do
      result =
        Spinner.new()
        |> Spinner.frame_rate(10)
        |> Spinner.run(fn -> {:ok, 42} end)

      assert result == {:ok, 42}
    end

    test "handles function that returns any value" do
      result =
        Spinner.new()
        |> Spinner.frame_rate(10)
        |> Spinner.run(fn -> "hello" end)

      assert result == "hello"
    end
  end

  describe "start/1 and stop/1" do
    test "starts and stops spinner process" do
      pid =
        Spinner.new()
        |> Spinner.frame_rate(10)
        |> Spinner.start()

      assert is_pid(pid)
      assert Process.alive?(pid)

      Spinner.stop(pid)

      # Give it a moment to clean up
      Process.sleep(50)
      refute Process.alive?(pid)
    end

    test "stop is idempotent" do
      pid =
        Spinner.new()
        |> Spinner.frame_rate(10)
        |> Spinner.start()

      Spinner.stop(pid)
      Process.sleep(50)

      # Calling stop again should not error
      assert Spinner.stop(pid) == :ok
    end
  end

  describe "update_text/2" do
    test "updates text on running spinner" do
      pid =
        Spinner.new()
        |> Spinner.text("Initial")
        |> Spinner.frame_rate(10)
        |> Spinner.start()

      assert Spinner.update_text(pid, "Updated") == :ok

      Spinner.stop(pid)
    end

    test "returns :ok for dead process" do
      pid =
        Spinner.new()
        |> Spinner.frame_rate(10)
        |> Spinner.start()

      Spinner.stop(pid)
      Process.sleep(50)

      # Should not error on dead process
      assert Spinner.update_text(pid, "Test") == :ok
    end
  end

  describe "theme integration" do
    test "applies theme colors when theme is set" do
      Esc.set_theme(:nord)

      result =
        Spinner.new(:dots)
        |> Spinner.text("Loading")
        |> Spinner.render()

      # Should have some ANSI coloring from theme
      assert result =~ "\e["

      Esc.clear_theme()
    end

    test "explicit styles override theme" do
      Esc.set_theme(:nord)

      custom_style = Esc.style() |> Esc.foreground(:red)

      result =
        Spinner.new(:dots)
        |> Spinner.spinner_style(custom_style)
        |> Spinner.render()

      # Should have red color, not theme emphasis color (basic or 256-color)
      assert result =~ "\e[31m" or result =~ "\e[38;5;1m"

      Esc.clear_theme()
    end

    test "no theme colors when use_theme is false" do
      Esc.set_theme(:nord)

      result =
        Spinner.new(:dots)
        |> Spinner.use_theme(false)
        |> Spinner.render()

      # Should not have any ANSI codes (just the raw frame)
      refute result =~ "\e["

      Esc.clear_theme()
    end
  end

  describe "frame width normalization" do
    test "pads shorter frames for consistent width" do
      # Moon spinner has emoji which are width 2
      # All renders should have same visual width
      spinner = Spinner.new(:moon)

      frame0 = Spinner.render(spinner, 0)
      frame1 = Spinner.render(spinner, 1)

      # Both should have same string length after padding
      assert String.length(frame0) == String.length(frame1)
    end
  end
end
