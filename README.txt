How to use gridmap:
1. Create a text file containing various symbols that will represent your game's map. Here's an example:

.#......#####.......
.#T.....#...#.......
G###################
.#....T.#T........#.
.#.....G#........G#.
.#......#.........#.
.#......#.........#.
####################
.#..#.......#..#....
.#..#.......#..#....
#########...#..#....
.#......#...#.G#####
.#......#...#..#....
.#......#...#..#....
.#......############
.#.............#....


2. When you initialize a new Gosu::Window, create a hash that contains the details needed to decode the symbols in your map. Here's an example:
symbol_details = {
			'#' => {type: 'road', connected: true, z: ZOrder::TILE},
			'G' => {type: 'garage', orientated: true},
			'T' => {type: 'tower', z: ZOrder::TOWER, offset_y: -10},
			'.' => {type: 'background'},
		}

Each symbol will cause a new tile to be created.
You can put any number of key - value pairs in this hash, and they will be accessible by calling the .details method on a tile. E.g:
	example_tile.details[:type]
	=> 'road'
If you want a certain type of tile to be the connected tile, you should set connected: true.
Tiles can also be :orientated - meaning they are not connected but their angle can still differ. By default all 'orientated' tiles will orientate themselves towards the nearest clockwise 'connected' tile, but you should change this as you wish by modifying the angle_orientated_tiles method.

3. Create another hash containing the paths to each image you plan to use for grid tiles. E.g:

image_path = "assets/images/"
		images = {
			buffer: 	image_path + 'background.bmp', #The buffer and block types are unused for this project. They could be left out of the hash.
			block: 		image_path + 'background.bmp', 
			straight: 	image_path + 'straight_road.bmp',
			corner: 	image_path + 'corner_junction.bmp',
			tri: 		image_path + 'tri_junction.bmp',
			quad: 		image_path + 'quad_junction.bmp',

			garage: 	image_path + 'garage.bmp',
			tower: 		image_path + 'tower_block.bmp',
			background: image_path + 'background.bmp'
		}

If you plan to use connected tiles, you should include the buffer, block, straight, corner, tri and quad keys in this hash.
They will be used to draw the 5 possible types of connected tile.
Any other keys included should correspond to the :type parameter you set for each symbol in the symbols hash.

4. Initialize a new gridmap, passing it the window, the path to your map, the symbols and image details hashes, then the size in pixels of your tiles.
@grid = Gridmap.new(self, "assets/roadmap.txt", symbol_details, images, 30)

Initializing a new grid calls two methods, make_grid and define_tiles.
 - make_grid adds all the tiles defined in your map file to the grid.

define_tiles does several things:
 - For each tile in the grid, it calculates which tiles adjacent to the tile are 'connected'. It saves this to the tile as an instance variable called connections. Connections is an array of the form [boolean, boolean, boolean, boolean] - in which each element refers to a specific direction, beginning above the tile and moving clockwise.
 - Every connected tile is assigned its image and angle based on its connections.
 - The angle_orientated_tiles method is called to set the angle of all orientated tiles (by default they are orientated towards the nearest clockwise 'connected' tile).
 - All non-connected tiles have their image set according to the images hash.

e.g: @grid.define_tiles(self, images)
6. In the game window's draw method, call draw tiles on your gridmap to draw all the tiles.

7. Use the useful methods provided by gridmap!
 - find_tile(x, y) returns the tile object with the given x, y co-ordinates (in pixels, not grid co-ordinates).
 - change_level(new_map, *p) will clear the grid and the reload it from a different map path which you specify with the new_map parameter. As optional parameters you can also pass a new symbol details hash, a new images hash, and a new tile size.

Check out the example project to see a working example.