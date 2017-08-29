defmodule Syms.World.Coordinates do
  @moduledoc """
  a container of coordinates {1, 5, 2}
  """
  def to_string({x, y, z}) do
    "#{x}#{y}#{z}"
  end
end
