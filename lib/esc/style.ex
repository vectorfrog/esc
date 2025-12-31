defmodule Esc.Style do
  @moduledoc """
  A style definition for terminal output.

  Styles are immutable structs that define how text should be rendered.
  Use the functions in `Esc` to build styles via pipelines.
  """

  @type color :: atom() | integer() | {integer(), integer(), integer()} | String.t()

  @type t :: %__MODULE__{
          foreground: color() | nil,
          background: color() | nil,
          bold: boolean(),
          italic: boolean(),
          underline: boolean(),
          strikethrough: boolean(),
          faint: boolean(),
          blink: boolean(),
          reverse: boolean(),
          padding_top: non_neg_integer(),
          padding_right: non_neg_integer(),
          padding_bottom: non_neg_integer(),
          padding_left: non_neg_integer(),
          margin_top: non_neg_integer(),
          margin_right: non_neg_integer(),
          margin_bottom: non_neg_integer(),
          margin_left: non_neg_integer(),
          border: atom() | Esc.Border.t() | nil,
          border_top: boolean(),
          border_right: boolean(),
          border_bottom: boolean(),
          border_left: boolean(),
          border_foreground: color() | nil,
          border_background: color() | nil,
          width: non_neg_integer() | nil,
          height: non_neg_integer() | nil,
          align_horizontal: :left | :center | :right,
          align_vertical: :top | :middle | :bottom,
          tab_width: non_neg_integer(),
          inline: boolean(),
          max_width: non_neg_integer() | nil,
          max_height: non_neg_integer() | nil,
          no_color: boolean(),
          renderer: (String.t(), t() -> String.t()) | nil
        }

  defstruct foreground: nil,
            background: nil,
            bold: false,
            italic: false,
            underline: false,
            strikethrough: false,
            faint: false,
            blink: false,
            reverse: false,
            padding_top: 0,
            padding_right: 0,
            padding_bottom: 0,
            padding_left: 0,
            margin_top: 0,
            margin_right: 0,
            margin_bottom: 0,
            margin_left: 0,
            border: nil,
            border_top: true,
            border_right: true,
            border_bottom: true,
            border_left: true,
            border_foreground: nil,
            border_background: nil,
            width: nil,
            height: nil,
            align_horizontal: :left,
            align_vertical: :top,
            tab_width: 4,
            inline: false,
            max_width: nil,
            max_height: nil,
            no_color: false,
            renderer: nil
end
