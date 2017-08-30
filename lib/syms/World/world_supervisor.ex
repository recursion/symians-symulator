defmodule Syms.World.Supervisor do
  use Supervisor
  @moduledoc """
  World Supervisor
  """

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_world(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  def init(:ok) do
    Supervisor.init([{Syms.World.Server, []}], strategy: :simple_one_for_one)
  end
end
