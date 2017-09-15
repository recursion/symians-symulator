defmodule Symulator do
  @moduledoc """
  Documentation for Symulator.
  """
  @doc """
  takes a string `name` and returns a PID for the created world
  returns {:noop, :already_exists} if a world with that name already exists
  """
  def create_world(name) do
    Symulator.World.Registry.create(Symulator.World.Registry, name)
  end
  def lookup(name) do
    Symulator.World.Registry.lookup(Symulator.World.Registry, name)
  end
end
