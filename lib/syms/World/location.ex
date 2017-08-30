defmodule Syms.World.Location do

  defstruct type: :empty, entities: []

  @moduledoc """
  a location has a type and a list of entities.
  """

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
