defmodule Esc.MixProject do
  use Mix.Project

  @version "0.4.0"
  @source_url "https://github.com/vectorfrog/esc"

  def project do
    [
      app: :esc,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Esc",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Declarative terminal styling for Elixir. Colors, borders, padding, layout, tables, trees, and interactive select menus."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Vectorfrog"]
    ]
  end

  defp docs do
    [
      main: "Esc",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
