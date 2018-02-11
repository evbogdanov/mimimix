defmodule Mimimix.Mixfile do
  use Mix.Project

  def project do
    [app: :mimimix,
     version: "0.0.2",
     elixir: "~> 1.0",
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Mimimix, []}]
  end

  defp deps do
    []
  end
end
