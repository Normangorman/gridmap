require 'gosu' 

class Gridmap < Array
	attr_reader :tile_width, :tile_height, :grid_width, :grid_height, :pixel_width, :pixel_height
  	def initialize(map_path, symbol_hash, tile_width, tile_height)
  		@tile_width, @tile_height = tile_width, tile_height

	   	IO.readlines(map_path).each_with_index do |line, y|
	      	gridline = []
	      	line.chomp.split("").each_with_index do |symbol, x|
	      		gridline << Tile.new(x, y, tile_width, tile_height, symbol_hash[symbol])
	     	end
	      	self << gridline
	    end

	    #Since all lines should contain the same number of characters, the width is set by counting the number of characters in the first line.
		@grid_width  = self.first.count - 1
		@grid_height = self.count - 1

		@pixel_width = @grid_width + 1 * tile_width
		@pixel_height = @grid_height + 1 * tile_height
	end

	def orientate_tiles(window, image_hash)
		
	end

	def draw_tiles
		self.each {|line| line.each {|tile| tile.draw_rot}}
	end
end

class Tile
	attr_reader :x, :y, :z
	attr_accessor :details, :connections, :orientation, :angle, :image
	def initialize(x, y, width, height, details)
		@x, @y, @width, @height, @details = x, y, width, height, details
		@z ||= ZOrder::TILE
		@angle ||= 0
	end

	def draw_rot
		# Half the height and half the width are added to the x, y co-ordinates because draw_rot draws the CENTRE of the image at the given co-ords.
		@image.draw_rot @x * @width + @width / 2, @y * @height + @height / 2, @z, @angle
	end
end

module ZOrder
  TILE, EXAMPLE = *(0..100)
end


class Controller < Gosu::Window
	def initialize
		symbol_hash = {
			'#' => {type: 'road', connected: true},
			'G' => {type: 'garage', connected: false},
			'T' => {type: 'tower', connected: false},
		}
		symbol_hash.default = {type: 'background', connected: false}
		image_path = "assets/images/"
		images = {
			straight: 		'assets/images/straight_road.bmp',
			corner: 		'assets/images/corner_junction.bmp',
			tri: 			'assets/images/tri_junction.bmp',
			quad: 			'assets/images/quad_junction.bmp',
		}
		images.default = 'assets/images/background.bmp'

		@grid = Gridmap.new("assets/roadmap.txt", symbol_hash, 30, 30)
		#Window must be defined before images can be defined.
		super(1000, 1000, fullscreen = false)
		orientate_tiles(images)
	end

	def orientate_tiles(images)
		#The check proc checks a tile with the given grid co-ordinates to see if it is connected or not.
		#The logic here prevents a tile from being checked if it lies outside the grid.
		check = Proc.new {|x, y| 	if y < 0 || x < 0 || y > @grid.grid_height || x > @grid.grid_width
												false
											else
												@grid[y][x].details[:connected]
											end }

		@grid.each_with_index do |line, y|
	      	line.each_with_index do |tile, x|
	      		connections    = [false, false, false, false] # up right down left
	      		connections[0] = check.call(x, y - 1) #up
				connections[1] = check.call(x + 1, y) #right
				connections[2] = check.call(x, y + 1) #down
				connections[3] = check.call(x - 1, y) #left
				tile.connections = connections

				case connections.count(true)
				when 1
					orientation = :straight
				when 2
					orientation = :corner
				when 3
					orientation = :tri
				when 4
					orientation = :quad
				else
					orientation = :background
				end

				tile.image = Gosu::Image.new(self, images[orientation], true)
				tile.orientation = orientation
	     	end
	    end
	end

	def update
	end

	def draw
		@grid.draw_tiles
	end

	def needs_cursor?
		true
	end

	def button_down(id)
	    case id
	    when Gosu::MsLeft
	    end
  	end
end

controller = Controller.new
controller.show