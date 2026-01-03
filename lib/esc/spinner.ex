defmodule Esc.Spinner do
  @moduledoc """
  Indeterminate loading indicator for terminal applications.

  Spinner provides animated feedback during long-running operations with
  multiple animation styles and full theme integration.

  ## Example

      alias Esc.Spinner

      Spinner.new()
      |> Spinner.text("Loading...")
      |> Spinner.run(fn ->
        fetch_remote_data()
      end)

  ## Block-based Execution

  The simplest way to use Spinner is with `run/2`, which handles all
  terminal state management automatically:

      result = Spinner.new(:arc)
      |> Spinner.text("Compiling...")
      |> Spinner.run(fn -> compile_project() end)

  ## Manual Start/Stop

  For operations where you need to update text during execution:

      pid = Spinner.new() |> Spinner.text("Starting...") |> Spinner.start()

      Spinner.update_text(pid, "Step 1 of 3...")
      do_step_1()

      Spinner.update_text(pid, "Step 2 of 3...")
      do_step_2()

      Spinner.stop(pid)

  ## Built-in Styles

  - `:dots` - Braille dots (default)
  - `:line` - Classic ASCII line
  - `:circle` - Quarter circles
  - `:arc` - Smooth arc
  - `:bounce` - Bouncing dot
  - `:arrows` - Rotating arrow
  - `:box` - Rotating box quadrant
  - `:pulse` - Pulsing block
  - `:moon` - Moon phases
  - `:clock` - Clock faces

  Or provide custom frames as a list of strings.

  ## Theme Integration

  When a global theme is set (via `Esc.set_theme/1`) and `use_theme` is enabled (default):

  - Spinner frames: theme `:emphasis` color
  - Text: theme `:muted` color

  Explicit styles override theme colors.
  """

  defstruct style: :dots,
            text: "",
            text_position: :right,
            text_style: nil,
            spinner_style: nil,
            frame_rate: 80,
            use_theme: true

  @type t :: %__MODULE__{
          style: atom() | [String.t()],
          text: String.t(),
          text_position: :left | :right,
          text_style: Esc.Style.t() | nil,
          spinner_style: Esc.Style.t() | nil,
          frame_rate: pos_integer(),
          use_theme: boolean()
        }

  # Built-in spinner frame sets
  @frames %{
    dots: ~w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏),
    line: ~w(- \\ | /),
    circle: ~w(◐ ◓ ◑ ◒),
    arc: ~w(◜ ◠ ◝ ◞ ◡ ◟),
    bounce: ~w(⠁ ⠂ ⠄ ⠂),
    arrows: ~w(← ↖ ↑ ↗ → ↘ ↓ ↙),
    box: ~w(▖ ▘ ▝ ▗),
    pulse: ~w(█ ▓ ▒ ░ ▒ ▓),
    moon: ~w(🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘),
    clock: ~w(🕛 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚)
  }

  @doc """
  Returns a list of available built-in spinner style names.
  """
  @spec styles() :: [atom()]
  def styles, do: Map.keys(@frames)

  @doc """
  Creates a new spinner with the default style (`:dots`).
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Creates a new spinner with the given style.

  Style can be an atom (built-in style) or a list of strings (custom frames).

  ## Examples

      Spinner.new(:arrows)
      Spinner.new([".", "..", "...", "...."])
  """
  @spec new(atom() | [String.t()]) :: t()
  def new(style) when is_atom(style) do
    unless Map.has_key?(@frames, style) do
      raise ArgumentError,
            "unknown spinner style #{inspect(style)}. Available: #{inspect(styles())}"
    end

    %__MODULE__{style: style}
  end

  def new(frames) when is_list(frames) do
    if Enum.empty?(frames) do
      raise ArgumentError, "custom frames list cannot be empty"
    end

    %__MODULE__{style: frames}
  end

  @doc """
  Sets the spinner animation style.

  ## Examples

      Spinner.new() |> Spinner.style(:circle)
      Spinner.new() |> Spinner.style(["⣾", "⣽", "⣻", "⢿"])
  """
  @spec style(t(), atom() | [String.t()]) :: t()
  def style(%__MODULE__{} = spinner, style) when is_atom(style) do
    unless Map.has_key?(@frames, style) do
      raise ArgumentError,
            "unknown spinner style #{inspect(style)}. Available: #{inspect(styles())}"
    end

    %{spinner | style: style}
  end

  def style(%__MODULE__{} = spinner, frames) when is_list(frames) do
    if Enum.empty?(frames) do
      raise ArgumentError, "custom frames list cannot be empty"
    end

    %{spinner | style: frames}
  end

  @doc """
  Sets the text shown alongside the spinner.
  """
  @spec text(t(), String.t()) :: t()
  def text(%__MODULE__{} = spinner, text) when is_binary(text) do
    %{spinner | text: text}
  end

  @doc """
  Sets whether text appears to the left or right of the spinner.

  Default is `:right`.

  ## Examples

      Spinner.new() |> Spinner.text("Working") |> Spinner.text_position(:left)
      # Output: "Working ⠋"
  """
  @spec text_position(t(), :left | :right) :: t()
  def text_position(%__MODULE__{} = spinner, position) when position in [:left, :right] do
    %{spinner | text_position: position}
  end

  @doc """
  Sets the style for the text.
  """
  @spec text_style(t(), Esc.Style.t()) :: t()
  def text_style(%__MODULE__{} = spinner, style) do
    %{spinner | text_style: style}
  end

  @doc """
  Sets the style for the spinner frames.
  """
  @spec spinner_style(t(), Esc.Style.t()) :: t()
  def spinner_style(%__MODULE__{} = spinner, style) do
    %{spinner | spinner_style: style}
  end

  @doc """
  Sets the frame delay in milliseconds.

  Default is 80ms.

  ## Examples

      Spinner.new() |> Spinner.frame_rate(100)  # Slower
      Spinner.new() |> Spinner.frame_rate(50)   # Faster
  """
  @spec frame_rate(t(), pos_integer()) :: t()
  def frame_rate(%__MODULE__{} = spinner, rate) when is_integer(rate) and rate > 0 do
    %{spinner | frame_rate: rate}
  end

  def frame_rate(%__MODULE__{}, rate) do
    raise ArgumentError, "frame_rate must be a positive integer, got: #{inspect(rate)}"
  end

  @doc """
  Enables or disables automatic theme colors.

  When enabled (default), the spinner uses theme colors for:
  - Spinner frames (`:emphasis` color)
  - Text (`:muted` color)

  Explicit styles override theme colors.
  """
  @spec use_theme(t(), boolean()) :: t()
  def use_theme(%__MODULE__{} = spinner, enabled) when is_boolean(enabled) do
    %{spinner | use_theme: enabled}
  end

  @doc """
  Renders a single frame of the spinner (for testing or custom loops).

  Returns the first frame by default.
  """
  @spec render(t()) :: String.t()
  def render(%__MODULE__{} = spinner), do: render(spinner, 0)

  @doc """
  Renders a specific frame of the spinner by index.
  """
  @spec render(t(), non_neg_integer()) :: String.t()
  def render(%__MODULE__{} = spinner, frame_index) when is_integer(frame_index) do
    frames = get_frames(spinner)
    frame = Enum.at(frames, rem(frame_index, length(frames)))

    # Normalize frame width for consistent display
    max_width = frames |> Enum.map(&display_width/1) |> Enum.max()
    padded_frame = pad_to_width(frame, max_width)

    spinner_style = get_effective_spinner_style(spinner)
    text_style = get_effective_text_style(spinner)

    styled_frame = apply_style(padded_frame, spinner_style)
    styled_text = apply_style(spinner.text, text_style)

    case {spinner.text, spinner.text_position} do
      {"", _} -> styled_frame
      {_, :right} -> styled_frame <> " " <> styled_text
      {_, :left} -> styled_text <> " " <> styled_frame
    end
  end

  @doc """
  Runs the spinner while executing a function.

  The spinner animates until the function completes, then stops and returns
  the function's result. Terminal state is always restored, even if the
  function raises an exception.

  ## Example

      result = Spinner.new()
      |> Spinner.text("Fetching data...")
      |> Spinner.run(fn ->
        Process.sleep(2000)
        {:ok, data}
      end)
  """
  @spec run(t(), (-> result)) :: result when result: var
  def run(%__MODULE__{} = spinner, fun) when is_function(fun, 0) do
    pid = start(spinner)

    try do
      fun.()
    after
      stop(pid)
    end
  end

  @doc """
  Starts the spinner animation in a separate process.

  Returns the process ID which can be used with `stop/1` and `update_text/2`.

  ## Example

      pid = Spinner.new() |> Spinner.text("Working...") |> Spinner.start()
      # ... do work ...
      Spinner.stop(pid)
  """
  @spec start(t()) :: pid()
  def start(%__MODULE__{} = spinner) do
    parent = self()

    pid =
      spawn_link(fn ->
        # Hide cursor
        IO.write("\e[?25l")

        loop(spinner, 0, parent)
      end)

    # Wait for spinner to be ready
    receive do
      {:spinner_ready, ^pid} -> pid
    after
      1000 -> pid
    end
  end

  @doc """
  Stops a running spinner and restores terminal state.

  This is idempotent - calling it multiple times or with an invalid pid is safe.
  """
  @spec stop(pid()) :: :ok
  def stop(pid) when is_pid(pid) do
    if Process.alive?(pid) do
      send(pid, :stop)

      # Wait for cleanup confirmation
      receive do
        {:spinner_stopped, ^pid} -> :ok
      after
        500 -> :ok
      end
    else
      :ok
    end
  end

  @doc """
  Updates the text of a running spinner.

  ## Example

      pid = Spinner.new() |> Spinner.start()
      Spinner.update_text(pid, "Step 1 of 3...")
      # ... work ...
      Spinner.update_text(pid, "Step 2 of 3...")
  """
  @spec update_text(pid(), String.t()) :: :ok
  def update_text(pid, text) when is_pid(pid) and is_binary(text) do
    if Process.alive?(pid) do
      send(pid, {:update_text, text})
    end

    :ok
  end

  # Animation loop
  defp loop(spinner, frame_index, parent) do
    # Notify parent we're ready (only on first frame)
    if frame_index == 0 do
      send(parent, {:spinner_ready, self()})
    end

    # Render current frame
    output = render(spinner, frame_index)
    IO.write("\r\e[K" <> output)

    # Wait for next frame or stop message
    receive do
      :stop ->
        # Clear line, show cursor, notify parent
        IO.write("\r\e[K\e[?25h")
        send(parent, {:spinner_stopped, self()})

      {:update_text, new_text} ->
        loop(%{spinner | text: new_text}, frame_index + 1, parent)
    after
      spinner.frame_rate ->
        loop(spinner, frame_index + 1, parent)
    end
  end

  # Get frames for the spinner (built-in or custom)
  defp get_frames(%__MODULE__{style: style}) when is_atom(style) do
    Map.fetch!(@frames, style)
  end

  defp get_frames(%__MODULE__{style: frames}) when is_list(frames) do
    frames
  end

  # Calculate display width (accounting for wide Unicode characters)
  defp display_width(string) do
    string
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      # Simple heuristic: emoji and CJK characters are width 2
      codepoint = char |> String.to_charlist() |> hd()

      width =
        cond do
          # Emoji ranges (simplified)
          codepoint >= 0x1F300 and codepoint <= 0x1F9FF -> 2
          # CJK
          codepoint >= 0x4E00 and codepoint <= 0x9FFF -> 2
          # Default
          true -> 1
        end

      acc + width
    end)
  end

  # Pad string to target display width
  defp pad_to_width(string, target_width) do
    current_width = display_width(string)
    padding = max(0, target_width - current_width)
    string <> String.duplicate(" ", padding)
  end

  # Apply style to text
  defp apply_style(text, nil), do: text
  defp apply_style("", _style), do: ""
  defp apply_style(text, style), do: Esc.render(style, text)

  # Theme-aware style resolution for spinner
  defp get_effective_spinner_style(spinner) do
    case {spinner.spinner_style, spinner.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :emphasis))

      _ ->
        nil
    end
  end

  # Theme-aware style resolution for text
  defp get_effective_text_style(spinner) do
    case {spinner.text_style, spinner.use_theme, Esc.get_theme()} do
      {style, _, _} when not is_nil(style) ->
        style

      {nil, true, theme} when not is_nil(theme) ->
        Esc.style()
        |> Esc.foreground(Esc.Theme.color(theme, :muted))

      _ ->
        nil
    end
  end
end
