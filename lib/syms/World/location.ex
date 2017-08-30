defmodule Syms.World.Location do
  alias Syms.World.Coordinates

  defstruct type: :empty, entities: []

  @moduledoc """
  a location has a type and a list of entities.
  """

  @doc """
      location: a key, value pair
      where the key is a set of coordinates as a string
      and the value is a location - currently a simple list
  """
  def create(coordinates) do
    {Coordinates.to_string(coordinates), %Syms.World.Location{}}
  end

  @doc """
  put an object on the top of the entities list.
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
  # TODO: get an object from the top of the entities list
  # TODO: iterate over all objects in the entities list
end
