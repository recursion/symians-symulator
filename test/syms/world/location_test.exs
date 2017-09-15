defmodule Syms.World.LocationTest do
  use ExUnit.Case, async: true
  
  describe "%Syms.World.Location{}" do
    setup do
      %{location: %Syms.World.Location{}}
    end
    test "defaults to type :empty", %{location: location} do
      assert location.type_ == :grass
    end
    test "has an empty entities list", %{location: location} do
      assert location.entities == []
    end
  end
end
