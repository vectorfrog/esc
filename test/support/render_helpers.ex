defmodule Esc.Test.RenderHelpers do
  @moduledoc """
  Test helpers for verifying rendered output.
  """

  @doc """
  Strips all ANSI escape codes from a string.
  Useful for testing content without style interference.
  """
  def strip_ansi(string) do
    String.replace(string, ~r/\e\[[0-9;]*m/, "")
  end

  @doc """
  Extracts all ANSI codes from a string.
  Returns a list of codes like ["1", "31", "0"].
  """
  def extract_ansi_codes(string) do
    Regex.scan(~r/\e\[([0-9;]+)m/, string)
    |> Enum.map(fn [_full, codes] -> codes end)
  end

  @doc """
  Returns the visible width of a string (excluding ANSI codes).
  """
  def visible_width(string) do
    string
    |> strip_ansi()
    |> String.length()
  end

  @doc """
  Returns the visible height (line count) of a string.
  """
  def visible_height(string) do
    string
    |> String.split("\n")
    |> length()
  end

  @doc """
  Returns {width, height} of the visible content.
  Width is the maximum line width.
  """
  def visible_dimensions(string) do
    lines = String.split(string, "\n")
    height = length(lines)
    width = lines |> Enum.map(&visible_width/1) |> Enum.max(fn -> 0 end)
    {width, height}
  end

  @doc """
  Checks if a string contains a specific ANSI code.

  ## Examples

      iex> has_ansi_code?("\e[1mhello\e[0m", "1")
      true

      iex> has_ansi_code?("\e[31mred\e[0m", "31")
      true
  """
  def has_ansi_code?(string, code) do
    string =~ ~r/\e\[#{Regex.escape(code)}m/
  end

  @doc """
  Checks if output has bold styling (ANSI code 1).
  """
  def has_bold?(string), do: has_ansi_code?(string, "1")

  @doc """
  Checks if output has italic styling (ANSI code 3).
  """
  def has_italic?(string), do: has_ansi_code?(string, "3")

  @doc """
  Checks if output has underline styling (ANSI code 4).
  """
  def has_underline?(string), do: has_ansi_code?(string, "4")

  @doc """
  Checks if output has a reset code (ANSI code 0).
  """
  def has_reset?(string), do: has_ansi_code?(string, "0")

  @doc """
  Checks for foreground color codes.

  ## Basic colors (30-37)
  - 30: black, 31: red, 32: green, 33: yellow
  - 34: blue, 35: magenta, 36: cyan, 37: white

  ## 256 color: 38;5;N
  ## True color: 38;2;R;G;B
  """
  def has_foreground_color?(string, :red), do: has_ansi_code?(string, "31")
  def has_foreground_color?(string, :green), do: has_ansi_code?(string, "32")
  def has_foreground_color?(string, :yellow), do: has_ansi_code?(string, "33")
  def has_foreground_color?(string, :blue), do: has_ansi_code?(string, "34")
  def has_foreground_color?(string, :magenta), do: has_ansi_code?(string, "35")
  def has_foreground_color?(string, :cyan), do: has_ansi_code?(string, "36")
  def has_foreground_color?(string, :white), do: has_ansi_code?(string, "37")
  def has_foreground_color?(string, :black), do: has_ansi_code?(string, "30")

  def has_foreground_color?(string, n) when is_integer(n) do
    string =~ ~r/\e\[38;5;#{n}m/
  end

  def has_foreground_color?(string, {r, g, b}) do
    string =~ ~r/\e\[38;2;#{r};#{g};#{b}m/
  end

  @doc """
  Checks for background color codes.

  ## Basic colors (40-47)
  ## 256 color: 48;5;N
  ## True color: 48;2;R;G;B
  """
  def has_background_color?(string, :red), do: has_ansi_code?(string, "41")
  def has_background_color?(string, :green), do: has_ansi_code?(string, "42")
  def has_background_color?(string, :yellow), do: has_ansi_code?(string, "43")
  def has_background_color?(string, :blue), do: has_ansi_code?(string, "44")
  def has_background_color?(string, :magenta), do: has_ansi_code?(string, "45")
  def has_background_color?(string, :cyan), do: has_ansi_code?(string, "46")
  def has_background_color?(string, :white), do: has_ansi_code?(string, "47")
  def has_background_color?(string, :black), do: has_ansi_code?(string, "40")

  def has_background_color?(string, n) when is_integer(n) do
    string =~ ~r/\e\[48;5;#{n}m/
  end

  def has_background_color?(string, {r, g, b}) do
    string =~ ~r/\e\[48;2;#{r};#{g};#{b}m/
  end

  @doc """
  Asserts that rendered output matches expected dimensions.
  Returns the output for further assertions.
  """
  def assert_dimensions(output, expected_width, expected_height) do
    {actual_width, actual_height} = visible_dimensions(output)

    if actual_width != expected_width do
      raise ExUnit.AssertionError,
        message: "Expected width #{expected_width}, got #{actual_width}\nOutput:\n#{output}"
    end

    if actual_height != expected_height do
      raise ExUnit.AssertionError,
        message: "Expected height #{expected_height}, got #{actual_height}\nOutput:\n#{output}"
    end

    output
  end

  @doc """
  Pretty prints rendered output with visible markers for debugging.
  Shows spaces as dots and newlines explicitly.
  """
  def debug_output(string) do
    string
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.map(fn {line, num} ->
      visible = strip_ansi(line) |> String.replace(" ", "·")
      "#{String.pad_leading(Integer.to_string(num), 2)}: #{visible} (#{visible_width(line)})"
    end)
    |> Enum.join("\n")
  end
end
