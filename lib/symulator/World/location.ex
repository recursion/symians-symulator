defmodule Symulator.World.Location do

  defstruct type_: :empty, entities: []

  @moduledoc """
  a location has a type and a list of entities.
  """

  @doc """
  put an object on the top of the entities list.
  """
  def put(location, object) do
    case location.entities do
      ## TODO: Some checks to make sure an object can be moved here
      nil -> location
      [] ->
        %{location | entities: [object] }
      [_] ->
        %{location | entities: [object] ++ location.entities}
    end
  end
  # TODO: get an object from the top of the entities list
  # TODO: iterate over all objects in the entities list
end
