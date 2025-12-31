defmodule Esc.Border do
  @moduledoc """
  Border styles for terminal boxes.
  """

  @type t :: %__MODULE__{
          top: String.t(),
          bottom: String.t(),
          left: String.t(),
          right: String.t(),
          top_left: String.t(),
          top_right: String.t(),
          bottom_left: String.t(),
          bottom_right: String.t()
        }

  defstruct [:top, :bottom, :left, :right, :top_left, :top_right, :bottom_left, :bottom_right]

  @doc """
  Returns a border style by name.

  Available styles: `:normal`, `:rounded`, `:thick`, `:double`, `:hidden`
  """
  @spec get(atom()) :: t() | nil
  def get(:normal) do
    %__MODULE__{
      top: "─",
      bottom: "─",
      left: "│",
      right: "│",
      top_left: "┌",
      top_right: "┐",
      bottom_left: "└",
      bottom_right: "┘"
    }
  end

  def get(:rounded) do
    %__MODULE__{
      top: "─",
      bottom: "─",
      left: "│",
      right: "│",
      top_left: "╭",
      top_right: "╮",
      bottom_left: "╰",
      bottom_right: "╯"
    }
  end

  def get(:thick) do
    %__MODULE__{
      top: "━",
      bottom: "━",
      left: "┃",
      right: "┃",
      top_left: "┏",
      top_right: "┓",
      bottom_left: "┗",
      bottom_right: "┛"
    }
  end

  def get(:double) do
    %__MODULE__{
      top: "═",
      bottom: "═",
      left: "║",
      right: "║",
      top_left: "╔",
      top_right: "╗",
      bottom_left: "╚",
      bottom_right: "╝"
    }
  end

  def get(:hidden) do
    %__MODULE__{
      top: " ",
      bottom: " ",
      left: " ",
      right: " ",
      top_left: " ",
      top_right: " ",
      bottom_left: " ",
      bottom_right: " "
    }
  end

  def get(:markdown) do
    %__MODULE__{
      top: "-",
      bottom: "-",
      left: "|",
      right: "|",
      top_left: "|",
      top_right: "|",
      bottom_left: "|",
      bottom_right: "|"
    }
  end

  def get(:ascii) do
    %__MODULE__{
      top: "-",
      bottom: "-",
      left: "|",
      right: "|",
      top_left: "+",
      top_right: "+",
      bottom_left: "+",
      bottom_right: "+"
    }
  end

  def get(_), do: nil

  @doc """
  Creates a custom border from a keyword list of characters.

  Unspecified characters default to the `:normal` border style.

  ## Options

  - `:top` - Top edge character
  - `:bottom` - Bottom edge character
  - `:left` - Left edge character
  - `:right` - Right edge character
  - `:top_left` - Top-left corner character
  - `:top_right` - Top-right corner character
  - `:bottom_left` - Bottom-left corner character
  - `:bottom_right` - Bottom-right corner character

  ## Examples

      iex> Border.custom(top: "=", bottom: "=")
      %Border{top: "=", bottom: "=", ...}
  """
  @spec custom(keyword()) :: t()
  def custom(opts) do
    normal = get(:normal)

    %__MODULE__{
      top: Keyword.get(opts, :top, normal.top),
      bottom: Keyword.get(opts, :bottom, normal.bottom),
      left: Keyword.get(opts, :left, normal.left),
      right: Keyword.get(opts, :right, normal.right),
      top_left: Keyword.get(opts, :top_left, normal.top_left),
      top_right: Keyword.get(opts, :top_right, normal.top_right),
      bottom_left: Keyword.get(opts, :bottom_left, normal.bottom_left),
      bottom_right: Keyword.get(opts, :bottom_right, normal.bottom_right)
    }
  end

  @doc """
  Lists all available border style names.
  """
  @spec styles() :: [atom()]
  def styles, do: [:normal, :rounded, :thick, :double, :hidden, :markdown, :ascii]
end
