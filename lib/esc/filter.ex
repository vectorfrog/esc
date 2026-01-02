defmodule Esc.Filter do
  @moduledoc """
  Shared filtering logic for interactive select components.

  Supports glob-style wildcard matching with `*` and case-insensitive substring matching.

  ## Pattern Matching

  - Without `*`: Substring match (implicit `*pattern*`)
  - With `*`: Glob-style match where `*` matches any characters

  ## Examples

      # Substring match
      Filter.matches?("redwood", "red")  # true
      Filter.matches?("darkred", "red")  # true

      # Glob patterns
      Filter.matches?("redwood", "red*")  # true
      Filter.matches?("darkred", "red*")  # false
      Filter.matches?("readme.md", "*.md")  # true
  """

  @doc """
  Compiles filter text into a pattern for matching.

  Returns `{:substring, pattern}` for simple substring matching,
  or a compiled `%Regex{}` for glob patterns with `*`.
  """
  @spec compile_pattern(String.t()) :: {:substring, String.t()} | Regex.t()
  def compile_pattern(""), do: {:substring, ""}

  def compile_pattern(filter_text) do
    filter_lower = String.downcase(filter_text)

    if String.contains?(filter_lower, "*") do
      # Glob mode: convert * to regex .*
      regex_pattern =
        filter_lower
        |> Regex.escape()
        |> String.replace("\\*", ".*")

      Regex.compile!("^" <> regex_pattern <> "$")
    else
      # Substring mode: implicit *pattern*
      {:substring, filter_lower}
    end
  end

  @doc """
  Checks if text matches the compiled pattern.
  """
  @spec matches?(String.t(), {:substring, String.t()} | Regex.t()) :: boolean()
  def matches?(_text, {:substring, ""}), do: true

  def matches?(text, {:substring, pattern}) do
    text
    |> String.downcase()
    |> String.contains?(pattern)
  end

  def matches?(text, %Regex{} = regex) do
    Regex.match?(regex, String.downcase(text))
  end

  @doc """
  Filters items by pattern, returning only those that match.

  Items can be strings or `{display_text, return_value}` tuples.
  Matching is done on the display text only.
  """
  @spec filter_items([item], String.t()) :: [item] when item: String.t() | {String.t(), term()}
  def filter_items(items, ""), do: items

  def filter_items(items, filter_text) do
    pattern = compile_pattern(filter_text)

    Enum.filter(items, fn item ->
      display_text = get_display_text(item)
      matches?(display_text, pattern)
    end)
  end

  @doc """
  Returns indices of items that match the filter pattern.

  Useful for preserving cursor position when filtering.
  """
  @spec matching_indices([item], String.t()) :: [non_neg_integer()]
        when item: String.t() | {String.t(), term()}
  def matching_indices([], _filter_text), do: []

  def matching_indices(items, "") do
    Enum.to_list(0..(length(items) - 1))
  end

  def matching_indices(items, filter_text) do
    pattern = compile_pattern(filter_text)

    items
    |> Enum.with_index()
    |> Enum.filter(fn {item, _idx} ->
      display_text = get_display_text(item)
      matches?(display_text, pattern)
    end)
    |> Enum.map(fn {_item, idx} -> idx end)
  end

  @doc """
  Renders the filter input line.

  ## Options

  - `:prompt` - The prompt text (default: "Filter: ")
  - `:prompt_style` - Style for the prompt
  - `:text_style` - Style for the filter text
  - `:show_cursor` - Whether to show cursor indicator (default: true when in filter mode)
  - `:match_count` - Tuple of {matched, total} to show count
  - `:count_style` - Style for match count
  """
  @spec render_filter_input(String.t(), boolean(), keyword()) :: String.t()
  def render_filter_input(filter_text, filter_mode, opts \\ []) do
    prompt = Keyword.get(opts, :prompt, "Filter: ")
    prompt_style = Keyword.get(opts, :prompt_style)
    text_style = Keyword.get(opts, :text_style)
    show_cursor = Keyword.get(opts, :show_cursor, filter_mode)
    match_count = Keyword.get(opts, :match_count)
    count_style = Keyword.get(opts, :count_style)

    styled_prompt = apply_style(prompt, prompt_style)
    styled_text = apply_style(filter_text, text_style)

    cursor = if show_cursor, do: "\u2588", else: ""

    count_part =
      case match_count do
        {matched, total} when matched < total ->
          count_text = " (#{matched}/#{total})"
          apply_style(count_text, count_style)

        _ ->
          ""
      end

    styled_prompt <> styled_text <> cursor <> count_part
  end

  @doc """
  Extracts display text from an item.
  """
  @spec get_display_text(String.t() | {String.t(), term()}) :: String.t()
  def get_display_text({text, _value}) when is_binary(text), do: text
  def get_display_text(text) when is_binary(text), do: text

  # Private helpers

  defp apply_style(text, nil), do: text
  defp apply_style(text, style), do: Esc.render(style, text)
end
