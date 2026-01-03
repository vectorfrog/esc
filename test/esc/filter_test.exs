defmodule Esc.FilterTest do
  use ExUnit.Case
  alias Esc.Filter

  describe "compile_pattern/1" do
    test "returns {:substring, \"\"} for empty string" do
      assert Filter.compile_pattern("") == {:substring, ""}
    end

    test "returns {:substring, lowercase} for text without wildcards" do
      assert Filter.compile_pattern("hello") == {:substring, "hello"}
      assert Filter.compile_pattern("HELLO") == {:substring, "hello"}
      assert Filter.compile_pattern("HeLLo") == {:substring, "hello"}
    end

    test "returns regex for text with wildcards" do
      pattern = Filter.compile_pattern("*.md")
      assert %Regex{} = pattern
    end

    test "converts * to .* in regex" do
      pattern = Filter.compile_pattern("red*")
      assert Regex.match?(pattern, "redwood")
      refute Regex.match?(pattern, "darkred")
    end

    test "handles multiple wildcards" do
      pattern = Filter.compile_pattern("*test*")
      assert Regex.match?(pattern, "testing")
      assert Regex.match?(pattern, "mytest123")
      assert Regex.match?(pattern, "test")
    end

    test "escapes regex special characters" do
      pattern = Filter.compile_pattern("file.txt")
      # The dot should be escaped, so it only matches literal dots
      assert {:substring, "file.txt"} = pattern
    end

    test "escapes regex special characters with wildcards" do
      pattern = Filter.compile_pattern("*.txt")
      assert Regex.match?(pattern, "file.txt")
      refute Regex.match?(pattern, "filetxt")  # dot should be escaped
    end
  end

  describe "matches?/2 with substring pattern" do
    test "matches empty pattern to anything" do
      assert Filter.matches?("anything", {:substring, ""})
      assert Filter.matches?("", {:substring, ""})
    end

    test "matches substring case-insensitively" do
      assert Filter.matches?("HelloWorld", {:substring, "world"})
      assert Filter.matches?("HELLO", {:substring, "hello"})
      # Pattern from compile_pattern is always lowercase
      assert Filter.matches?("hello", {:substring, "hello"})
    end

    test "matches partial substrings" do
      assert Filter.matches?("redwood", {:substring, "red"})
      assert Filter.matches?("darkred", {:substring, "red"})
      assert Filter.matches?("darkredwood", {:substring, "red"})
    end

    test "returns false for no match" do
      refute Filter.matches?("hello", {:substring, "world"})
      refute Filter.matches?("abc", {:substring, "xyz"})
    end
  end

  describe "matches?/2 with regex pattern" do
    test "matches start wildcard" do
      pattern = Filter.compile_pattern("*wood")
      assert Filter.matches?("redwood", pattern)
      assert Filter.matches?("DRIFTWOOD", pattern)
      refute Filter.matches?("woody", pattern)
    end

    test "matches end wildcard" do
      pattern = Filter.compile_pattern("red*")
      assert Filter.matches?("redwood", pattern)
      assert Filter.matches?("REDO", pattern)
      refute Filter.matches?("darkred", pattern)
    end

    test "matches middle wildcard" do
      pattern = Filter.compile_pattern("r*d")
      assert Filter.matches?("red", pattern)
      assert Filter.matches?("read", pattern)
      assert Filter.matches?("ROAD", pattern)
      refute Filter.matches?("ready", pattern)
    end

    test "matches multiple wildcards" do
      pattern = Filter.compile_pattern("*e*")
      assert Filter.matches?("red", pattern)
      assert Filter.matches?("hello", pattern)
      assert Filter.matches?("test", pattern)
      refute Filter.matches?("abc", pattern)
    end

    test "matches file extension pattern" do
      pattern = Filter.compile_pattern("*.md")
      assert Filter.matches?("readme.md", pattern)
      assert Filter.matches?("CHANGELOG.MD", pattern)
      refute Filter.matches?("file.txt", pattern)
      refute Filter.matches?("mdfile", pattern)
    end
  end

  describe "filter_items/2" do
    test "returns all items for empty filter" do
      items = ["a", "b", "c"]
      assert Filter.filter_items(items, "") == items
    end

    test "filters string items" do
      items = ["apple", "banana", "apricot", "cherry"]
      result = Filter.filter_items(items, "ap")
      assert result == ["apple", "apricot"]
    end

    test "filters tuple items by display text" do
      items = [
        {"Apple", :apple},
        {"Banana", :banana},
        {"Apricot", :apricot}
      ]
      result = Filter.filter_items(items, "ap")
      assert result == [{"Apple", :apple}, {"Apricot", :apricot}]
    end

    test "filters case-insensitively" do
      items = ["Hello", "WORLD", "hello world"]
      result = Filter.filter_items(items, "hello")
      assert result == ["Hello", "hello world"]
    end

    test "filters with wildcard pattern" do
      items = ["readme.md", "file.txt", "docs.md", "script.sh"]
      result = Filter.filter_items(items, "*.md")
      assert result == ["readme.md", "docs.md"]
    end

    test "returns empty list when nothing matches" do
      items = ["apple", "banana", "cherry"]
      result = Filter.filter_items(items, "xyz")
      assert result == []
    end
  end

  describe "matching_indices/2" do
    test "returns all indices for empty filter" do
      items = ["a", "b", "c"]
      assert Filter.matching_indices(items, "") == [0, 1, 2]
    end

    test "returns indices of matching items" do
      items = ["apple", "banana", "apricot", "cherry"]
      result = Filter.matching_indices(items, "ap")
      assert result == [0, 2]  # "apple" at 0, "apricot" at 2
    end

    test "returns indices for tuple items" do
      items = [
        {"Apple", :a},
        {"Banana", :b},
        {"Apricot", :c}
      ]
      result = Filter.matching_indices(items, "ap")
      assert result == [0, 2]
    end

    test "returns empty list when nothing matches" do
      items = ["apple", "banana"]
      result = Filter.matching_indices(items, "xyz")
      assert result == []
    end

    test "works with wildcard patterns" do
      items = ["readme.md", "file.txt", "docs.md"]
      result = Filter.matching_indices(items, "*.md")
      assert result == [0, 2]
    end

    test "returns empty list for empty items" do
      assert Filter.matching_indices([], "") == []
      assert Filter.matching_indices([], "test") == []
    end
  end

  describe "render_filter_input/3" do
    test "renders default prompt" do
      result = Filter.render_filter_input("", false)
      assert result == "Filter: "
    end

    test "renders filter text" do
      result = Filter.render_filter_input("hello", false)
      assert result == "Filter: hello"
    end

    test "shows cursor in filter mode" do
      result = Filter.render_filter_input("hello", true)
      assert result == "Filter: hello█"
    end

    test "hides cursor outside filter mode" do
      result = Filter.render_filter_input("hello", false)
      refute String.contains?(result, "█")
    end

    test "uses custom prompt" do
      result = Filter.render_filter_input("test", false, prompt: "Search: ")
      assert result == "Search: test"
    end

    test "shows match count when filtered" do
      result = Filter.render_filter_input("test", false, match_count: {5, 10})
      assert result == "Filter: test (5/10)"
    end

    test "hides match count when all match" do
      result = Filter.render_filter_input("test", false, match_count: {10, 10})
      assert result == "Filter: test"
    end

    test "applies prompt style" do
      style = Esc.style() |> Esc.foreground(:cyan)
      result = Filter.render_filter_input("", false, prompt_style: style)
      assert result =~ "\e[36m"  # cyan color code
    end

    test "applies text style" do
      style = Esc.style() |> Esc.bold()
      result = Filter.render_filter_input("test", false, text_style: style)
      assert result =~ "\e[1m"  # bold code
    end

    test "applies count style" do
      style = Esc.style() |> Esc.faint()
      result = Filter.render_filter_input("test", false,
        match_count: {5, 10},
        count_style: style
      )
      assert result =~ "\e[2m"  # faint code
    end
  end

  describe "get_display_text/1" do
    test "returns string as-is" do
      assert Filter.get_display_text("hello") == "hello"
    end

    test "extracts display text from tuple" do
      assert Filter.get_display_text({"Display", :value}) == "Display"
    end

    test "handles empty string" do
      assert Filter.get_display_text("") == ""
    end

    test "handles tuple with empty display" do
      assert Filter.get_display_text({"", :value}) == ""
    end
  end

  describe "page_indices/4" do
    test "returns all indices when page_size is 0" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.page_indices(items, "", 0, 0) == [0, 1, 2, 3, 4]
    end

    test "returns all indices when page_size is nil" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.page_indices(items, "", nil, 0) == [0, 1, 2, 3, 4]
    end

    test "returns first page of indices" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.page_indices(items, "", 2, 0) == [0, 1]
    end

    test "returns second page of indices" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.page_indices(items, "", 2, 1) == [2, 3]
    end

    test "returns partial last page" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.page_indices(items, "", 2, 2) == [4]
    end

    test "works with filtered items" do
      items = ["apple", "banana", "apricot", "cherry", "avocado"]
      # Filtered indices for "a*" = [0, 2, 4] (apple, apricot, avocado)
      assert Filter.page_indices(items, "a*", 2, 0) == [0, 2]
      assert Filter.page_indices(items, "a*", 2, 1) == [4]
    end

    test "returns empty list for out of bounds page" do
      items = ["a", "b", "c"]
      assert Filter.page_indices(items, "", 2, 5) == []
    end
  end

  describe "total_pages/3" do
    test "returns 1 when page_size is 0" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.total_pages(items, "", 0) == 1
    end

    test "returns 1 when page_size is nil" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.total_pages(items, "", nil) == 1
    end

    test "returns correct page count" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.total_pages(items, "", 2) == 3
      assert Filter.total_pages(items, "", 3) == 2
      assert Filter.total_pages(items, "", 5) == 1
      assert Filter.total_pages(items, "", 10) == 1
    end

    test "works with filtered items" do
      items = ["apple", "banana", "apricot", "cherry", "avocado"]
      # Filtered count for "a*" = 3 (apple, apricot, avocado)
      assert Filter.total_pages(items, "a*", 2) == 2
    end

    test "returns 1 for empty items" do
      assert Filter.total_pages([], "", 10) == 1
    end
  end

  describe "clamp_page/4" do
    test "returns same page when valid" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.clamp_page(1, items, "", 2) == 1
    end

    test "clamps to last page when too high" do
      items = ["a", "b", "c", "d", "e"]
      assert Filter.clamp_page(10, items, "", 2) == 2
    end

    test "clamps to 0 when negative" do
      items = ["a", "b", "c"]
      assert Filter.clamp_page(-1, items, "", 2) == 0
    end
  end

  describe "render_pagination/3" do
    test "returns empty string for single page" do
      assert Filter.render_pagination(0, 1, []) == ""
    end

    test "renders page indicator" do
      result = Filter.render_pagination(0, 5, [])
      assert result == "[Page 1/5]"
    end

    test "renders correct page number (1-indexed)" do
      assert Filter.render_pagination(2, 5, []) == "[Page 3/5]"
    end

    test "applies style" do
      style = Esc.style() |> Esc.foreground(:cyan)
      result = Filter.render_pagination(0, 5, style: style)
      assert result =~ "\e[36m"  # cyan color code
    end
  end
end
