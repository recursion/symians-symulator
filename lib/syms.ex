defmodule Syms do
  @moduledoc """
  Documentation for Syms.
  """
  use Application

  def start(_type, _args) do
     Syms.Supervisor.start_link(name: Syms.Supervisor)
  end

  def create_world(opts) do
    Syms.World.start_link(opts)
  end
end
