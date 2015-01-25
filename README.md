Mimimix
======

Mimimix is Elixir code reloader. It watches the files in Elixir and Erlang directories, and if any files change, Mimimix will automatically recompile and reload your application.

### Installation

1. Create a new application:
  mix new my_app

2. Add to deps:
  ```elixir
  defp deps do
    [{:mimimix, github: "evbogdanov/mimimix", only: :dev}]
  end
  ```

3. Add `:mimimix` as a development-only app:
  ```elixir
  def application do
    dev_apps = case Mix.env == :dev do
      true -> [:mimimix]
      false -> []
    end
    [applications: dev_apps ++ my_apps]
  end
  ```

### Usage

Just modify your Elixir code (in the **lib** directory) or Erlang code (**src** directory), and Mimimix will do the rest.
