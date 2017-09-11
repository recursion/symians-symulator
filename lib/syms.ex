defmodule Syms do
  @moduledoc """
  Documentation for Syms.
  """
  @doc """
  takes a string `name` and returns a PID for the created world
  returns {:noop, :already_exists} if a world with that name already exists
  """
  def create_world(name) do
    Syms.World.Registry.create(Syms.World.Registry, name)
  end
  def lookup(name) do
    Syms.World.Registry.lookup(Syms.World.Registry, name)
  end
end
