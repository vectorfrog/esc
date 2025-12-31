defmodule Esc.ColorTest do
  use ExUnit.Case
  alias Esc.Color

  describe "foreground/1" do
    test "basic named colors produce correct codes" do
      assert Color.foreground(:black) == "\e[30m"
      assert Color.foreground(:red) == "\e[31m"
      assert Color.foreground(:green) == "\e[32m"
      assert Color.foreground(:yellow) == "\e[33m"
      assert Color.foreground(:blue) == "\e[34m"
      assert Color.foreground(:magenta) == "\e[35m"
      assert Color.foreground(:cyan) == "\e[36m"
      assert Color.foreground(:white) == "\e[37m"
    end

    test "bright colors use 256 palette" do
      assert Color.foreground(:bright_black) == "\e[38;5;8m"
      assert Color.foreground(:bright_red) == "\e[38;5;9m"
      assert Color.foreground(:bright_green) == "\e[38;5;10m"
      assert Color.foreground(:bright_white) == "\e[38;5;15m"
    end

    test "256 palette integers" do
      assert Color.foreground(0) == "\e[38;5;0m"
      assert Color.foreground(196) == "\e[38;5;196m"
      assert Color.foreground(255) == "\e[38;5;255m"
    end

    test "RGB tuples produce true color codes" do
      assert Color.foreground({255, 0, 0}) == "\e[38;2;255;0;0m"
      assert Color.foreground({0, 255, 0}) == "\e[38;2;0;255;0m"
      assert Color.foreground({0, 0, 255}) == "\e[38;2;0;0;255m"
      assert Color.foreground({125, 86, 244}) == "\e[38;2;125;86;244m"
    end

    test "hex strings convert to RGB" do
      assert Color.foreground("#ff0000") == "\e[38;2;255;0;0m"
      assert Color.foreground("#00ff00") == "\e[38;2;0;255;0m"
      assert Color.foreground("#0000ff") == "\e[38;2;0;0;255m"
      assert Color.foreground("#7d56f4") == "\e[38;2;125;86;244m"
    end

    test "invalid colors return empty string" do
      assert Color.foreground(:invalid) == ""
      assert Color.foreground(-1) == ""
      assert Color.foreground(256) == ""
      assert Color.foreground("#gg0000") == ""
    end
  end

  describe "background/1" do
    test "basic named colors produce correct codes" do
      assert Color.background(:black) == "\e[40m"
      assert Color.background(:red) == "\e[41m"
      assert Color.background(:green) == "\e[42m"
      assert Color.background(:yellow) == "\e[43m"
      assert Color.background(:blue) == "\e[44m"
      assert Color.background(:magenta) == "\e[45m"
      assert Color.background(:cyan) == "\e[46m"
      assert Color.background(:white) == "\e[47m"
    end

    test "bright colors use 256 palette" do
      assert Color.background(:bright_black) == "\e[48;5;8m"
      assert Color.background(:bright_red) == "\e[48;5;9m"
    end

    test "256 palette integers" do
      assert Color.background(0) == "\e[48;5;0m"
      assert Color.background(196) == "\e[48;5;196m"
      assert Color.background(255) == "\e[48;5;255m"
    end

    test "RGB tuples produce true color codes" do
      assert Color.background({255, 0, 0}) == "\e[48;2;255;0;0m"
      assert Color.background({125, 86, 244}) == "\e[48;2;125;86;244m"
    end

    test "hex strings convert to RGB" do
      assert Color.background("#7d56f4") == "\e[48;2;125;86;244m"
    end
  end

  describe "color degradation" do
    test "rgb_to_ansi256 converts colors correctly" do
      # Pure red
      assert Color.rgb_to_ansi256(255, 0, 0) == 196
      # Pure green
      assert Color.rgb_to_ansi256(0, 255, 0) == 46
      # Pure blue
      assert Color.rgb_to_ansi256(0, 0, 255) == 21
      # White
      assert Color.rgb_to_ansi256(255, 255, 255) == 231
      # Black
      assert Color.rgb_to_ansi256(0, 0, 0) == 16
      # Gray
      assert Color.rgb_to_ansi256(128, 128, 128) in 243..245
    end

    test "ansi256_to_ansi16 converts colors correctly" do
      # Basic colors map to themselves
      assert Color.ansi256_to_ansi16(0) == 0
      assert Color.ansi256_to_ansi16(1) == 1
      assert Color.ansi256_to_ansi16(7) == 7

      # Bright colors
      assert Color.ansi256_to_ansi16(8) == 8
      assert Color.ansi256_to_ansi16(15) == 15

      # Extended palette maps to closest basic color
      assert Color.ansi256_to_ansi16(196) == 1  # Bright red -> red
      assert Color.ansi256_to_ansi16(21) == 4   # Blue-ish -> blue
    end
  end

  describe "adaptive colors" do
    test "adaptive_color selects dark variant on dark background" do
      # adaptive(light_bg_color, dark_bg_color)
      # When background is dark, use the dark variant (second arg)
      color = Color.adaptive(:dark_text, :light_text)

      assert Color.resolve_adaptive(color, :dark) == :light_text
    end

    test "adaptive_color selects light variant on light background" do
      color = Color.adaptive(:dark_text, :light_text)

      assert Color.resolve_adaptive(color, :light) == :dark_text
    end
  end

  describe "complete colors" do
    test "complete_color provides all three representations" do
      color = Color.complete(
        ansi: :red,
        ansi256: 196,
        true_color: {255, 0, 0}
      )

      assert color.ansi == :red
      assert color.ansi256 == 196
      assert color.true_color == {255, 0, 0}
    end

    test "resolve_complete returns appropriate value for profile" do
      color = Color.complete(
        ansi: :red,
        ansi256: 196,
        true_color: {255, 0, 0}
      )

      assert Color.resolve_complete(color, :ansi) == :red
      assert Color.resolve_complete(color, :ansi256) == 196
      assert Color.resolve_complete(color, :true_color) == {255, 0, 0}
    end

    test "resolve_complete falls back when level not specified" do
      color = Color.complete(
        ansi: :red,
        true_color: {255, 0, 0}
      )

      # Missing ansi256 should fall back to ansi
      assert Color.resolve_complete(color, :ansi256) == :red
    end
  end
end
