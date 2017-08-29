defmodule Syms do
  @moduledoc """
  Documentation for Syms.
  """
  def create_world(name \\ "unnamed_world") do
    Syms.World.Registry.create(Syms.World.Registry, name)
  end
end
