defmodule Syms.World do
  use GenServer

  @moduledoc """
  a world is a %Map{} of locations keyed by coordinates
  `dimensions` is the length, width, and height of the world
  """
  defstruct dimensions: {0, 0, 0}, locations: %{}

  @doc """
  Creates an empty world
  """
  def start_link(options \\ []) do
    GenServer.start_link(Syms.World.Server, :ok, options)
  end

  @doc """
  generate a world from dimensions
  """
  def generate(world, dimensions) do
    GenServer.cast(world, {:generate, dimensions})
  end

  @doc """
  return the world struct
  """
  def view(world) do
    GenServer.call(world, {:view})
  end

  @doc """
  returns the location stored in the key `coordinates`
  """
  def get(world, coordinates) do
    GenServer.call(world, {:get, coordinates})
  end

  @doc """
  put location at coordinates
  """
  def put(world, coordinates, location) do
    GenServer.call(world, {:put, coordinates, location})
  end
end
