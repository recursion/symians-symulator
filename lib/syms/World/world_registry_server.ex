defmodule Syms.World.RegistryServer do
    ## Server callbacks

    def init(table) do
        worlds = :ets.new(table, [:named_table, read_concurrency: true])
        refs  = %{}
        {:ok, {worlds, refs}}
    end

    def handle_call({:create, name}, _from, {worlds, refs}) do
        case Syms.World.Registry.lookup(worlds, name) do
            {:ok, _pid} ->
                {:reply, {worlds, refs}}
            :error ->
                {:ok, pid} = Syms.World.Supervisor.start_world()
                ref = Process.monitor(pid)
                refs = Map.put(refs, ref, name)
                :ets.insert(worlds, {name, pid})
                {:reply,pid, {worlds, refs}}
            end

    end
    
    def handle_info({:DOWN, ref, :process, _pid, _reason}, {worlds, refs}) do
        {name, refs} = Map.pop(refs, ref)
        :ets.delete(worlds, name)
        {:noreply, {worlds, refs}}
    end
    
    def handle_info(_msg, state) do
        {:noreply, state}
    end
end