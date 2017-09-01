# Syms
##### A simple, distributed, multi-user world 'symulator': built in elixir
### Goals
Generate a 3D 'World' which is ultimately a matrix of 'locations'
Generate entities which interact with the world in various ways
Allow (web) clients to view/interact with the world

**TODO:**
* Consolidate the world storage mechanisms
  - [ ] Decide on implementation for entities, locations, and players
        - Im considering that each of these may need to be their own processes 
              - certainly entities and players will need to be at the least.... but we may be able to get away with leaving locations connected to the world as they are. 
              - I guess the question becomes... if so much state is stored in each location, then should'nt it be its own agent/genserver?
        - a player/connection 'subscribes' to their location data by:
             1 player process regularly poll's the :ets table for the location data they need
             2 diff it for changes
             3 send updates over their websocket channel.
  - [ ] Create functions for grabbing subsets of the world
    - i.e. get all locations within X range of a given coordinate 
    - get all locations within {length, width, height} starting at a given coordinate
    

**IN Progress**
  - [x] Link up to phoenix
  - [x] Create a basic front-end


**Done**
  - [x] Currently there is a bit of a mishmash between storing world state in a %Syms.World{} map and the :ets cache. Locations are being stored individually by coordinate key in :ets.I think that generating the entire locations map and storing it might make more sense because it will allow easier manipulation. (We can just grab the entire locations map, instead of having to generate all the coordinates every time we want the whole map, which should actually be rare.) I think the idea here will be to store everything in :ets and just put it into the %Syms.World{} map when we are sending it out of the server
