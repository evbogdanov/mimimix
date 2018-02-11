defmodule Mimimix do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(Mimimix.Worker, [])]
    opts = [strategy: :one_for_one, name: Mimimix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule Worker do
    use GenServer

    def lib, do: "lib" # elixir dir
    def src, do: "src" # erlang dir

    defmodule State, do: defstruct last_mtime: nil

    def start_link do
      Process.send_after(__MODULE__, :poll_and_reload, 10000)
      GenServer.start_link(__MODULE__, %State{last_mtime: nil}, name: Mimimix.Worker)
    end

    def handle_info(:poll_and_reload, state) do
      {dir, current_mtime} = get_mtime()

      state = if state.last_mtime != current_mtime do
        if dir == src() do
          IO.puts "Compiling Erlang..."
          Mix.Tasks.Compile.Erlang.run([]) # not enough
          scan(src()) # extra work to do
        else
          IO.puts "Compiling Elixir..."
          Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
        end
        %State{last_mtime: current_mtime}
      end

      Process.send_after(__MODULE__, :poll_and_reload, 1000)
      {:noreply, state}
    end

    @doc """
    get the latest modification time
    """
    def get_mtime do
      mtime_lib = get_mtime lib()
      mtime_src = get_mtime src()
      if mtime_lib > mtime_src do
        {lib(), mtime_lib}
      else
        {src(), mtime_src}
      end
    end

    def get_mtime(dir) do
      case File.ls(dir) do
        {:ok, files} -> get_mtime(files, [], dir)
        _ -> nil
      end
    end

    def get_mtime([], mtimes, _dir) do
      mtimes |> Enum.sort |> List.last
    end

    def get_mtime([h|t], mtimes, dir) do
      mtime = case File.dir?("#{dir}/#{h}") do
        true -> get_mtime("#{dir}/#{h}")
        false -> File.stat!("#{dir}/#{h}").mtime
      end
      get_mtime(t, [mtime|mtimes], dir)
    end

    @doc """
    find erlang modules and reload 'em
    """
    def scan(dir) do
      {:ok, contents} = File.ls(dir)
      Enum.each contents, fn(cont) ->
        case File.dir?("#{dir}/#{cont}") do
          true -> scan("#{dir}/#{cont}")
          false -> reload(cont)
        end
      end
    end

    def reload(file) do
      if String.contains?(file, ".erl") do
        m = file |> String.replace(".erl", "") |> String.to_atom
        :code.soft_purge(m)
        :code.load_file(m)
        IO.puts "Reloaded :#{m}"
      end
    end
  end
end
