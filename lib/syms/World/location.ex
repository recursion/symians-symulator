defmodule Syms.World.Coordinates do
  @moduledoc """
  a container of coordinates
      # Shape:
          {0, 1, 0}
  """
  def to_string({x, y, z}) do
    "#{x}#{y}#{z}"
  end
end

defmodule Syms.World.Location do
  alias Syms.World.Coordinates

  @moduledoc """
      a location is a data structure that has coordinates
      and has a queue for storing items/game objects
  """
  @location []

  @doc """
      location: a key, value pair
      where the key is a set of coordinates as a string
      and the value is a location - currently a simple list
  """
  def create(coordinates) do
    {Coordinates.to_string(coordinates), @location}
  end

  @doc """
  put an object on the top of a location
  """
  def put(location, object) do
    case location do
      ## TODO: Some checks to make sure an object can be moved here
      nil -> []
      [] ->
        [object]
      [_] ->
        [object] ++ location
    end
  end
end
