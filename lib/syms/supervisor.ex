defmodule Syms.Supervisor do
    use Supervisor
  
    def start_link(opts) do
      Supervisor.start_link(__MODULE__, :ok, opts)
    end
  
    def init(:ok) do
      children = [
          Syms.World.Supervisor,
          {Syms.World.Registry, name: Syms.World.Registry}
      ]
  
      Supervisor.init(children, strategy: :one_for_all)
    end
end