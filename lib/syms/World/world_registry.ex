defmodule Syms.World.Registry do
    use GenServer
  
    ## Client API
  
    @doc """
    Starts the registry.
    """
    def start_link(opts) do
      server = Keyword.fetch!(opts, :name)
      GenServer.start_link(__MODULE__, server, opts)
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
    creates a world associated with the given `name` in `server`.
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

    ## Server callbacks

    def init(table) do
        worlds = :ets.new(table, [:named_table, read_concurrency: true])
        refs  = %{}
        {:ok, {worlds, refs}}
    end

    def handle_call({:create, name}, _from, {worlds, refs}) do
        case Syms.World.Registry.lookup(worlds, name) do
            {:ok, _pid} ->
                {:reply, {:noop, :already_exists}, {worlds, refs}}
            :error ->
                {:ok, pid} = Syms.World.Supervisor.start_world()
                ref = Process.monitor(pid)
                refs = Map.put(refs, ref, name)
                :ets.insert(worlds, {name, pid})
                {:reply, pid, {worlds, refs}}
            end

    end
    
    def handle_info({:DOWN, ref, :process, _pid, _reason}, {worlds, refs}) do
        case Map.pop(refs, ref) do
            {name, refs} -> 
                :ets.delete(worlds, name)
                {:noreply, {worlds, refs}}
            _ -> 
                {:noreply, {worlds, refs}}

        end
    end
    
    def handle_info(_, state) do
        {:noreply, state}
    end
  end