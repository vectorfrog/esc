defmodule Esc.List do
  @moduledoc """
  Styled hierarchical lists for terminal output.

  Lists support various enumerator styles and can be nested.

  ## Example

      List.new(["First item", "Second item", "Third item"])
      |> List.enumerator(:arabic)
      |> List.render()

  ## Enumerators

  Available built-in enumerators:
  - `:bullet` - Bullet points (•)
  - `:dash` - Dashes (-)
  - `:arabic` - Arabic numerals (1., 2., 3.)
  - `:roman` - Roman numerals (i., ii., iii.)
  - `:alphabet` - Alphabetic (a., b., c.)

  Custom enumerators can be functions that take an index and return a string.

  ## Nesting

  Lists can contain other lists for nested structures:

      nested = List.new(["Sub-item 1", "Sub-item 2"])
      List.new(["Main item", nested])
      |> List.render()
  """

  defstruct items: [],
            enumerator: :bullet,
            enumerator_style: nil,
            item_style: nil,
            indent: 0

  @type item :: String.t() | t()

  @type t :: %__MODULE__{
          items: [item()],
          enumerator: atom() | (non_neg_integer() -> String.t()),
          enumerator_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          indent: non_neg_integer()
        }

  @doc """
  Creates a new list with the given items.
  """
  @spec new([item()]) :: t()
  def new(items \\ []) when is_list(items) do
    %__MODULE__{items: items}
  end

  @doc """
  Adds an item to the list.
  """
  @spec item(t(), item()) :: t()
  def item(%__MODULE__{} = list, item) do
    %{list | items: list.items ++ [item]}
  end

  @doc """
  Sets the enumerator style.

  Built-in options: `:bullet`, `:dash`, `:arabic`, `:roman`, `:alphabet`

  Can also be a function that takes an index and returns a string.
  """
  @spec enumerator(t(), atom() | (non_neg_integer() -> String.t())) :: t()
  def enumerator(%__MODULE__{} = list, enum) do
    %{list | enumerator: enum}
  end

  @doc """
  Sets the style for enumerators.
  """
  @spec enumerator_style(t(), Esc.Style.t()) :: t()
  def enumerator_style(%__MODULE__{} = list, style) do
    %{list | enumerator_style: style}
  end

  @doc """
  Sets the style for list items.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = list, style) do
    %{list | item_style: style}
  end

  @doc """
  Sets the base indentation level.
  """
  @spec indent(t(), non_neg_integer()) :: t()
  def indent(%__MODULE__{} = list, spaces) when is_integer(spaces) and spaces >= 0 do
    %{list | indent: spaces}
  end

  @doc """
  Renders the list to a string.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{items: []}), do: ""

  def render(%__MODULE__{} = list) do
    render_items(list.items, list, 0)
    |> Enum.join("\n")
  end

  defp render_items(items, list, depth) do
    base_indent = String.duplicate(" ", list.indent + depth * 2)

    {lines, _} =
      Enum.reduce(items, {[], 0}, fn item, {acc, idx} ->
        case item do
          %__MODULE__{} = nested ->
            # Nested list - render with increased depth (doesn't increment parent index)
            nested_lines = render_items(nested.items, merge_styles(nested, list), depth + 1)
            {acc ++ nested_lines, idx}

          text when is_binary(text) ->
            enum_text = get_enumerator(list.enumerator, idx)

            styled_enum =
              if list.enumerator_style do
                Esc.render(list.enumerator_style, enum_text)
              else
                enum_text
              end

            styled_item =
              if list.item_style do
                Esc.render(list.item_style, text)
              else
                text
              end

            {acc ++ [base_indent <> styled_enum <> styled_item], idx + 1}
        end
      end)

    lines
  end

  defp merge_styles(nested, parent) do
    %{nested |
      enumerator_style: nested.enumerator_style || parent.enumerator_style,
      item_style: nested.item_style || parent.item_style,
      indent: parent.indent
    }
  end

  defp get_enumerator(:bullet, _idx), do: "• "
  defp get_enumerator(:dash, _idx), do: "- "
  defp get_enumerator(:arabic, idx), do: "#{idx + 1}. "
  defp get_enumerator(:roman, idx), do: "#{to_roman(idx + 1)}. "
  defp get_enumerator(:alphabet, idx), do: "#{to_alphabet(idx)}. "
  defp get_enumerator(func, idx) when is_function(func, 1), do: func.(idx)

  defp to_roman(n) when n <= 0, do: ""
  defp to_roman(n) when n >= 1000, do: "m" <> to_roman(n - 1000)
  defp to_roman(n) when n >= 900, do: "cm" <> to_roman(n - 900)
  defp to_roman(n) when n >= 500, do: "d" <> to_roman(n - 500)
  defp to_roman(n) when n >= 400, do: "cd" <> to_roman(n - 400)
  defp to_roman(n) when n >= 100, do: "c" <> to_roman(n - 100)
  defp to_roman(n) when n >= 90, do: "xc" <> to_roman(n - 90)
  defp to_roman(n) when n >= 50, do: "l" <> to_roman(n - 50)
  defp to_roman(n) when n >= 40, do: "xl" <> to_roman(n - 40)
  defp to_roman(n) when n >= 10, do: "x" <> to_roman(n - 10)
  defp to_roman(n) when n >= 9, do: "ix" <> to_roman(n - 9)
  defp to_roman(n) when n >= 5, do: "v" <> to_roman(n - 5)
  defp to_roman(n) when n >= 4, do: "iv" <> to_roman(n - 4)
  defp to_roman(n) when n >= 1, do: "i" <> to_roman(n - 1)

  defp to_alphabet(idx) do
    <<97 + rem(idx, 26)>>
  end
end
