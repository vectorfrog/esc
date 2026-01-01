defmodule Esc.Theme.Store do
  @moduledoc """
  Global theme state management.

  Uses `persistent_term` for efficient reads (themes are read frequently,
  set rarely). Falls back to application config for static configuration.

  ## Usage

      # Set theme by name
      Esc.Theme.Store.set(:nord)

      # Set custom theme
      Esc.Theme.Store.set(%Esc.Theme{...})

      # Get current theme
      Esc.Theme.Store.get()

      # Clear theme
      Esc.Theme.Store.clear()
  """

  alias Esc.Theme

  @key {__MODULE__, :current_theme}

  @doc """
  Sets the global theme.

  Accepts either a theme name atom (e.g., `:nord`) or a `%Esc.Theme{}` struct.

  ## Examples

      iex> Esc.Theme.Store.set(:nord)
      :ok

      iex> Esc.Theme.Store.set(:unknown)
      {:error, :unknown_theme}
  """
  @spec set(atom() | Theme.t()) :: :ok | {:error, :unknown_theme}
  def set(theme_name) when is_atom(theme_name) do
    case Esc.Theme.Palette.get(theme_name) do
      nil -> {:error, :unknown_theme}
      theme -> set(theme)
    end
  end

  def set(%Theme{} = theme) do
    :persistent_term.put(@key, theme)
    :ok
  end

  @doc """
  Gets the current theme, or nil if not set.

  First checks `persistent_term`, then falls back to `Application.get_env(:esc, :theme)`.

  ## Examples

      iex> Esc.Theme.Store.set(:nord)
      iex> Esc.Theme.Store.get()
      %Esc.Theme{name: :nord, ...}

      iex> Esc.Theme.Store.clear()
      iex> Esc.Theme.Store.get()
      nil
  """
  @spec get() :: Theme.t() | nil
  def get do
    case :persistent_term.get(@key, :not_set) do
      :not_set ->
        # Fall back to application config
        case Application.get_env(:esc, :theme) do
          nil -> nil
          name when is_atom(name) -> Esc.Theme.Palette.get(name)
          %Theme{} = theme -> theme
        end

      theme ->
        theme
    end
  end

  @doc """
  Clears the current theme.

  After clearing, `get/0` will fall back to application config or return nil.

  ## Examples

      iex> Esc.Theme.Store.set(:nord)
      iex> Esc.Theme.Store.clear()
      :ok
      iex> Esc.Theme.Store.get()
      nil
  """
  @spec clear() :: :ok
  def clear do
    :persistent_term.erase(@key)
    :ok
  end
end
