# Syms
##### A world 'symulator: built in elixir
### Goals
Generate a 3D 'World' which is ultimately a matrix of 'locations'
Generate entities which interact with the world in various ways
Allow (web) clients to view/interact with the world

**TODO: everything!**
* Consolidate the world storage mechanisms
  * Currently there is a bit of a mishmash between storing world state in a %Syms.World{} map and the :ets cache. Locations are being stored individually by coordinate key in :ets.I think that generating the entire locations map and storing it might make more sense because it will allow easier manipulation. (We can just grab the entire locations map, instead of having to generate all the coordinates every time we want the whole map, which should actually be rare.) I think the idea here will be to store everything in :ets and just put it into the %Syms.World{} map when we are sending it out of the server
  * Create functions for grabbing subsets of the world
    * i.e. get all locations within X range of a given coordinate 
    * get all locations within {length, width, height} starting at a given coordinate
