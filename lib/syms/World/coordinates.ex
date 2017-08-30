defmodule Syms.World.Coordinates do
  @moduledoc """
  a container of coordinates {1, 5, 2}
  """
  def to_string({x, y, z}) do
    "#{x}|#{y}|#{z}"
  end

  def from_string(string) do
    [l, w, h] =
      String.split(string, "|")
      |> Enum.map(&Integer.parse(&1))
      |> Enum.map(fn {n, _} -> n end)
    {l, w, h}
  end
end
