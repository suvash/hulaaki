defmodule Hulaaki.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :hulaaki,
      version: @version,
      name: "Hulaaki",
      elixir: "~> 1.3",
      source_url: "https://github.com/suvash/hulaaki",
      homepage_url: "https://github.com/suvash/hulaaki",
      deps: deps(),
      docs: &docs/0,
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:inch_ex, "~> 0.5.6", only: :docs},
      {:earmark, "~> 1.2.4", only: [:dev, :docs]},
      {:ex_doc, "~> 0.18.2", only: [:dev, :docs]},
      {:dialyze, "~> 0.2.1", only: :test},
      {:excoveralls, "~> 0.8.1", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    An Elixir library (driver) for clients communicating with MQTT brokers(via the MQTT 3.1.1 protocol).
    """
  end

  defp package do
    [
      maintainers: ["Suvash Thapaliya"],
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
      licenses: ["MIT"],
      links: %{Github: "https://github.com/suvash/hulaaki"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: "https://github.com/suvash/hulaaki"
    ]
  end
end
