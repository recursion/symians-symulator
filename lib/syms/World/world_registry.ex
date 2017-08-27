defmodule Syms.World.Registry do
    use GenServer
  
    ## Client API
  
    @doc """
    Starts the registry.
    """
    def start_link(opts) do
      server = Keyword.fetch!(opts, :name)
      GenServer.start_link(Syms.World.RegistryServer, server, opts)
    end
  
    @doc """
    Looks up the world pid for `name` stored in `server`.
  
    Returns `{:ok, pid}` if the world exists, `:error` otherwise.
    """
    def lookup(server, name) do
        case :ets.lookup(server, name) do
            [{^name, pid}] -> {:ok, pid}
            [] -> :error
        end
    end
  
    @doc """
    Ensures there is a world associated with the given `name` in `server`.
    """
    def create(server, name) do
      GenServer.call(server, {:create, name})
    end
  

    @doc """
    Stops the registry.
    """
    def stop(server) do
        GenServer.stop(server)
    end
  end