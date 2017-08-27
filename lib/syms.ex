defmodule Syms do
  @moduledoc """
  Documentation for Syms.
  """
  use Application

  def start(_type, _args) do
     Syms.Supervisor.start_link(name: Syms.Supervisor)
  end

end
