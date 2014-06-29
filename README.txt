How to use Gridmap:
When you initialize the game window, call Gridmap.new with the following parameters:
	map_path = The path to the text file containing your map.
	symbol_hash = 	A hash in which the symbols in your map file are the keys. 
			The values can be any object. 
			If a value is a hash: 
				the key :image sets the Tile's @image to the key's value. (this should be a Gosu::Image)
				the key :image_path sets an instance variable @image_path to the given value.
					This is useful if you want to initiate the grid before the game window is fully initialized.
					e.g. you want the number of tiles in the grid to determine the game window's dimensions.
					If you then call draw on the tile, you must pass a hash containing a key :window with the game window as its value.
	tile_width = The width in pixels of the tiles in your map.
	tile_height = The height in pixels of the tiles in your map.