defmodule Symulator.World do
  use GenServer, restart: :temporary
  @moduledoc """
  a world is a structure containing:
    `name`: a string representing the worlds name - used for :ets storage
    `locations`: a %Map{} of locations where the key is the
      locations coordinates
    `dimensions` is the length, width, and height of the world
  """
  defstruct name: "", dimensions: {0, 0, 0}, locations: %{}

  @doc """
  Creates a named, empty world
  HACK: args is currently only used from tests that use start_supervised
    when start_supervised is called, name comes in as an atom 
    otherwise the name comes in under name
  """
  def start_link(args, name \\ "THE UNNAMED") do
    name = if is_atom(args), do: Atom.to_string(args), else: name
    GenServer.start_link(Symulator.World.Server, [name: name], [])
  end

  @doc """
  generate a map of locations sized from dimensions`
  """
  def generate(world, dimensions) do
    GenServer.cast(world, {:generate, dimensions})
  end

  @doc """
  return the world struct
  """
  def get(world) do
    GenServer.call(world, {:get})
  end

  @doc """
  returns the location stored in the key `coordinates`
  """
  def get(world, coordinates) do
    GenServer.call(world, {:get, coordinates})
  end

  @doc """
  put a location at coordinates
  """
  def put(world, coordinates, location = %Symulator.World.Location{}) do
    GenServer.call(world, {:put, coordinates, location})
  end

  @doc """
  takes a tuple of dimensions and a callback
  callback must return a key, value tuple: {key, value}
  invokes callback on each set of generated coordinates
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
      {coords, %Symulator.World.Location{}}
    end)
  end

  @doc """
  task for running generate_locations
  returns each location as it is generated
  """
  def generate_locations(dimensions, parent) do
    Task.start(fn ->
      map(dimensions, fn coords ->
        send(parent, {:location_generated, coords})
      end)
      # send a done message here?
    end)
  end

  @doc """
  create a task to generate locations
  sends locations once they are all generated
  """
  def generate_locations(dimensions, parent, start_time) do
    Task.start(fn ->
      locations = generate_locations(dimensions)
      gen_time = Time.diff(Time.utc_now(), start_time, :millisecond)
      send(parent, {:locations_generated, locations, gen_time})
    end)
  end
end
