defmodule Syms.World do
  alias Syms.World.Location
  @moduledoc """
  a world is a structure containing:
    `locations`: a %Map{} of locations where the key is the locations coordinates
    `dimensions` is the length, width, and height of the world
  """
  defstruct dimensions: {0, 0, 0}, locations: %{}

  @doc """
  takes a tuple of dimensions and a callback

  generates every combination of coordinates within a matrix of provided dimensions
  invokes the callback on each set of generated coordinates

  returns a %Map{}
  """
  def map({length, width, height}, callback) do
    for l <- 0..length,
      w <- 0..width,
      h <- 0..height,
      into: %{},
      do: callback.({l, w, h})
  end

  @doc """
  create a location for every possible coordinate within the given dimensions
  """
  def generate_locations(dimensions) do
    map(dimensions, fn coords ->
      Location.create(coords)
    end)
  end

  @doc """
  create a task to generate locations
  send result to `parent` when the job is done
  """
  def generate_locations(dimensions, parent, start_time) do
    Task.start(fn ->
      locations = generate_locations(dimensions)
      gen_time = Time.diff(Time.utc_now(), start_time, :millisecond)
      send(parent, {:locations_generated, dimensions, locations, gen_time})
    end)
  end
end
