defmodule Esc.Tree do
  @moduledoc """
  Styled tree structures for terminal output.

  Trees display hierarchical data with branch connectors.

  ## Example

      Tree.root("Project")
      |> Tree.child("src")
      |> Tree.child("lib")
      |> Tree.child("test")
      |> Tree.render()

  ## Enumerators

  Available enumerator styles:
  - `:default` - Standard box-drawing characters (├──, └──, │)
  - `:rounded` - Rounded final branch (├──, ╰──, │)

  ## Nesting

  Trees can contain other trees for nested structures:

      subtree = Tree.root("Nested") |> Tree.child("Leaf")
      Tree.root("Root") |> Tree.child(subtree) |> Tree.render()

  ## Theme Integration

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default),
  the tree automatically uses theme colors:

  - Root text: theme `:emphasis` color (bold)
  - Connectors: theme `:muted` color

  Explicit styles override theme colors. Use `use_theme(tree, false)` to disable.
  """

  defstruct root: nil,
            children: [],
            enumerator: :default,
            root_style: nil,
            item_style: nil,
            enumerator_style: nil,
            use_theme: true

  @type child :: String.t() | t()

  @type t :: %__MODULE__{
          root: String.t() | nil,
          children: [child()],
          enumerator: :default | :rounded,
          root_style: Esc.Style.t() | nil,
          item_style: Esc.Style.t() | nil,
          enumerator_style: Esc.Style.t() | nil,
          use_theme: boolean()
        }

  @doc """
  Creates a new empty tree.
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Creates a tree with a root label.
  """
  @spec root(String.t()) :: t()
  def root(label) when is_binary(label) do
    %__MODULE__{root: label}
  end

  @doc """
  Adds a child to the tree.

  Children can be strings or nested trees.
  """
  @spec child(t(), child()) :: t()
  def child(%__MODULE__{} = tree, child) do
    %{tree | children: tree.children ++ [child]}
  end

  @doc """
  Sets the enumerator style.

  - `:default` - Standard characters (├──, └──)
  - `:rounded` - Rounded last branch (├──, ╰──)
  """
  @spec enumerator(t(), :default | :rounded) :: t()
  def enumerator(%__MODULE__{} = tree, style) when style in [:default, :rounded] do
    %{tree | enumerator: style}
  end

  @doc """
  Sets the style for the root node.
  """
  @spec root_style(t(), Esc.Style.t()) :: t()
  def root_style(%__MODULE__{} = tree, style) do
    %{tree | root_style: style}
  end

  @doc """
  Sets the style for child items.
  """
  @spec item_style(t(), Esc.Style.t()) :: t()
  def item_style(%__MODULE__{} = tree, style) do
    %{tree | item_style: style}
  end

  @doc """
  Sets the style for tree connectors (├──, └──, │).
  """
  @spec enumerator_style(t(), Esc.Style.t()) :: t()
  def enumerator_style(%__MODULE__{} = tree, style) do
    %{tree | enumerator_style: style}
  end

  @doc """
  Enables or disables automatic theme colors.

  When enabled (default), the tree uses theme colors for:
  - Root text (`:emphasis` color, bold)
  - Connectors (`:muted` color)

  Explicit styles (via `root_style/2`, `enumerator_style/2`) override theme colors.

  ## Examples

      # Disable theme colors
      Tree.root("Project") |> Tree.use_theme(false)
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = tree, enabled) when is_boolean(enabled) do
    %{tree | use_theme: enabled}
  end

  @doc """
  Renders the tree to a string.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{root: nil, children: []}), do: ""

  def render(%__MODULE__{} = tree) do
    lines = []

    # Render root with effective style
    lines =
      if tree.root do
        root_style = get_effective_root_style(tree)

        root_text =
          if root_style do
            Esc.render(root_style, tree.root)
          else
            tree.root
          end

        lines ++ [root_text]
      else
        lines
      end

    # Render children
    lines = lines ++ render_children(tree.children, tree, "")

    Enum.join(lines, "\n")
  end

  defp render_children([], _tree, _prefix), do: []

  defp render_children(children, tree, prefix) do
    last_idx = length(children) - 1

    children
    |> Enum.with_index()
    |> Enum.flat_map(fn {child, idx} ->
      is_last = idx == last_idx
      render_child(child, tree, prefix, is_last)
    end)
  end

  defp render_child(child, tree, prefix, is_last) when is_binary(child) do
    {branch, _continuation} = get_connectors(tree.enumerator, is_last)
    enumerator_style = get_effective_enumerator_style(tree)

    styled_branch =
      if enumerator_style do
        Esc.render(enumerator_style, branch)
      else
        branch
      end

    styled_item =
      if tree.item_style do
        Esc.render(tree.item_style, child)
      else
        child
      end

    [prefix <> styled_branch <> styled_item]
  end

  defp render_child(%__MODULE__{} = subtree, tree, prefix, is_last) do
    {branch, continuation} = get_connectors(tree.enumerator, is_last)
    enumerator_style = get_effective_enumerator_style(tree)

    # Render subtree root
    styled_branch =
      if enumerator_style do
        Esc.render(enumerator_style, branch)
      else
        branch
      end

    root_text = subtree.root || ""

    styled_root =
      if tree.item_style do
        Esc.render(tree.item_style, root_text)
      else
        root_text
      end

    root_line = prefix <> styled_branch <> styled_root

    # Render subtree children with updated prefix
    new_prefix = prefix <> continuation
    merged_tree = merge_styles(subtree, tree)
    child_lines = render_children(subtree.children, merged_tree, new_prefix)

    [root_line | child_lines]
  end

  defp merge_styles(subtree, parent) do
    %{subtree |
      enumerator: subtree.enumerator,
      root_style: subtree.root_style || parent.root_style,
      item_style: subtree.item_style || parent.item_style,
      enumerator_style: subtree.enumerator_style || parent.enumerator_style,
      use_theme: subtree.use_theme && parent.use_theme
    }
  end

  defp get_connectors(:default, false), do: {"├── ", "│   "}
  defp get_connectors(:default, true), do: {"└── ", "    "}
  defp get_connectors(:rounded, false), do: {"├── ", "│   "}
  defp get_connectors(:rounded, true), do: {"╰── ", "    "}

  # Theme-aware style resolution

  # Gets effective root style: explicit style > theme style > nil
  defp get_effective_root_style(tree) do
    case {tree.root_style, tree.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        # Explicit style takes precedence
        style

      {nil, true, theme} when not is_nil(theme) ->
        # Use theme colors
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :emphasis))
        |> Esc.bold()

      _ ->
        nil
    end
  end

  # Gets effective enumerator style: explicit style > theme style > nil
  defp get_effective_enumerator_style(tree) do
    case {tree.enumerator_style, tree.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        # Explicit style takes precedence
        style

      {nil, true, theme} when not is_nil(theme) ->
        # Use theme colors
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
