Moonrealm 0.4.2 by paramat
For latest stable Minetest compatible back to 0.4.6
Depends default
Licenses: Code WTFPL, textures CC BY-SA
Moonstone and moondust textures are recoloured default textures: sand by VanessaE and stone by Perttu Ahola
Pine sapling, needles and ice textures by Splizard.

Fly and teleport up to y = 15000, it will generate below you.
The top 2 chunk layers (160m depth) contain the surface and are lua generated. Underground i have used Pilzadam's nether mod method to quickly turn air to stone, after that lua generates fissure type cave systems. The underground part of this realm is of unlimited depth.
Moondust depth is determined by 3D perlin noise and has smooth transitions / randomness at edges.
The cave systems become narrower as they approach the surface and often intersect the surface at low altitudes creating twisting ravines.
Underground the optional lux ore creates basic cave illumination. Mined lux ore drops lux crystals, 9 can be crafted into a bright lux node.
Maximum chunk generation time on my old slow laptop is 40 seconds for the lower surface chunks, underground chunks are much faster. Progress is printed to terminal to ease the wait.

New stuff in version 0.3.0:

New mapgen using the sum of 2 perlin noises having scales in the golden ratio (207/128).
5 colours of moondust (grey, brown, orange, yellow, white) pattern defined by perlin noise.
The average terrain level (noise offset centre) is now varied by perln noise.
Orange tinted atmosphere nodes return:
    Now generated fast using 'register ore' method.
    Simplified to 1 node instead of 5, tint is subtle and constant throughout atmosphere and caves.
    Optional.
    Parameters for tint colour and alpha.
    Atmosphere fills holes created by digging nodes.

New stuff in version 0.4.1:

Moondusts are no longer falling nodes.
Mese blocks and iron ore.
Water ice at high altitudes in moondust and glows gently in the moonlight (light source = 1).
Water ice can be crafted to default:water_source.
Moonstone brick node and slabs.
Lux crystals are defined as a fuel with a longer burntime than coal.
Moonstone can be crafted into default:furnace.
Moonglass cooked from moondust1.
Life support air nodes that spread by abm, replacing tinted atmosphere and default "air" but do not pass through thick walls. Beware diagonal leaks, a single leak can spread out of control and cause abm meltdown, the air spread abm can be disabled by parameter if this happens.
Life support air generators add nodes around itself when placed.
Airlock nodes with illumination.
Hydroponic liquid crafted from old leaves and water ice, slightly more viscous than water.
Only moondust5 is suitable as hydroponic bedding, hydroponic liquid 'source' or 'flowing' will saturate neighbouring moondust5 nodes turning them into moonsoil, in this you can plant a space pine sapling, this will only grow when planted in moonsoil beneath either "air" or "moonrealm:air".
Removing hydroponic liquid will cause moonsoil to dry out and revert to moondust5.
Space pines are specially bred compact evergreens for oxygen regeneration and general cool vibage.

New stuff in version 0.4.2:

Liquid hydrocarbon lakes, parameters for colour, transparency, surface level y.
Lakebeds are a few nodes thick and seal the lake from flowing into the fissures ... which is fun but needs to be done carefully because the structure of the fissures creates a giant underground spreading of waterfalls from a single leak.

Crafting

default water source
I
I = waterice

luxnode
CCC
CCC
CCC
C = luxcrystal

airgen
SIS
ILI
SIS
S = steel ingot
I = waterice
L = luxnode

hlsource
NNN
NIN
NNN
N = moonrealm:needles
I = waterice

airlock
S-S
SLS
S-S
S = steel ingot
L = luxnode

moonstonebrick x 4
MM
MM
M = moonstone

moonstoneslab x 4
MM
M = moonstone

default furnace
MMM
M-M
MMM
M = moonstone
