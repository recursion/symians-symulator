defmodule Syms.World.Supervisor do
    use Supervisor
  
    @name Syms.World.Supervisor
    
    def start_link(_opts) do
      Supervisor.start_link(__MODULE__, :ok, name: @name)
    end
  
    def start_world do
        Supervisor.start_child(@name, [])
    end

    def init(:ok) do
        Supervisor.init([Syms.World], strategy: :simple_one_for_one)
    end
end