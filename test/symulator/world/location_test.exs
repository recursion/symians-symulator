defmodule Symulator.World.LocationTest do
  use ExUnit.Case, async: true
  
  describe "%Symulator.World.Location{}" do
    setup do
      %{location: %Symulator.World.Location{}}
    end
    test "defaults to type :empty", %{location: location} do
      assert location.type_ == :empty
    end
    test "has an empty entities list", %{location: location} do
      assert location.entities == []
    end
  end
  describe "Location.put" do
    setup do
      %{location: %Symulator.World.Location{}}
    end
    test "adds an object to location.entities", %{location: location} do
      nextLocation = Symulator.World.Location.put(location,  "grass")
      assert nextLocation.entities == ["grass"]
    end
  end
end
