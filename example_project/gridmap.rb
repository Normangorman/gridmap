require 'gosu' 

class Gridmap < Array
	attr_reader :tile_size, :grid_width, :grid_height, :pixel_width, :pixel_height, :connected_tiles, :orientated_tiles
  	def initialize(map_path, symbol_details, tile_size)
  		@tile_size = tile_size
  		@connected_tiles = []
  		@orientated_tiles = []

	   	IO.readlines(map_path).each_with_index do |line, y|
	      	gridline = []
	      	line.chomp.split("").each_with_index do |symbol, x|
	      		t = Tile.new(x, y, tile_size, symbol_details[symbol])
	      		gridline 			<< t
	      		@connected_tiles 	<< t if t.details[:connected]
	      		@orientated_tiles 	<< t if t.details[:orientated]
	     	end
	      	self << gridline
	    end

	    #Since all lines should contain the same number of characters, the width is set by counting the number of characters in the first line.
		@grid_width  = self.first.count - 1
		@grid_height = self.count - 1

		@pixel_width = (@grid_width + 1) * tile_size
		@pixel_height = (@grid_height + 1) * tile_size
	end

	def define_tiles(window, images)
		#The check method checks a tile with the given grid co-ordinates to see if it is connected or not.
		#The logic here prevents a tile from being checked if it lies outside the grid.
		def check(x, y)
			if y < 0 || x < 0 || y > @grid_height || x > @grid_width
				false
			elsif self[y][x].details[:connected] || self[y][x].details[:orientated]
				true
			else
				false
			end
		end 

		#Works out connections for connected or orientated tiles.
		(@connected_tiles + @orientated_tiles).each do |tile|
	      	connections    = [false, false, false, false] # up right down left
	      	connections[0] = check(tile.x, tile.y - 1) #up
			connections[1] = check(tile.x + 1, tile.y) #right
			connections[2] = check(tile.x, tile.y + 1) #down
			connections[3] = check(tile.x - 1, tile.y) #left
			tile.connections = connections
		end

		#Sets image and angle for connected tiles based on their connections.
		@connected_tiles.each do |tile|
			case tile.connections.count(true)
			when 0
				img_key = :block
			when 1
				img_key = :straight
				tile.angle = 90 if tile.connections[1] || tile.connections[3]
			when 2
				if tile.connections == [true, false, true, false]
					img_key = :straight
				elsif tile.connections == [false, true, false, true]
					img_key = :straight
					tile.angle = 90
				else
					img_key = :corner
					case tile.connections
					when [false, true, true, false]
						#angle does not need to change
					when [false, false, true, true]
						tile.angle = 90
					when [true, false, false, true]
						tile.angle = 180
					when [true, true, false, false]
						tile.angle = 270
					end
				end
			when 3
				img_key = :tri
				for n in 0..3
					tile.angle = 90 * n if tile.connections[n] == false
				end
			when 4
				img_key = :quad
			end

			tile.image = Gosu::Image.new(window, images[img_key], true)
		end

		angle_orientated_tiles

		#Sets image for all non-connected tiles.
		self.each do |line|
			line.each do |tile|
				unless tile.details[:connected]
					#img_key is inferred from the tile's type!
					img_key = tile.details[:type].to_sym
					tile.image = Gosu::Image.new(window, images[img_key], true)
				end
			end
		end
	end

	def angle_orientated_tiles
		#Sets angle for orientated tiles based on nearest connected tile in a clockwise direction.
		#CHANGE THIS METHOD AS YOU WISH.
		@orientated_tiles.each do |t1|
		    @connected_tiles.each do |t2|
		    	if t2.y == t1.y - 1
		    		#dont change from default angle
		    	elsif t2.x == t1.x + 1
		    		t1.angle = 90
		    	elsif t2.y == t1.y + 1
		    		t1.angle = 180
		    	elsif t2.x == t1.x - 1
		    		t1.angle = 270
		    	else
		    		#dont change from default angle
		    	end
		    end
		end
	end

	def draw_tiles
		self.each {|line| line.each {|tile| tile.draw}}
	end

	def find_tile(x, y)
		self[(y / @tile_size).floor][(x / @tile_size).floor]
	end
end

class Tile
	attr_reader :x, :y
	attr_accessor :angle, :centre_point, :connections, :details, :image, :z
	def initialize(x, y, size, details)
		@x, @y, @size, @details = x, y, size, details
		
		@offset_x 	= details[:offset_x] if details[:offset_x]
		@offset_y 	= details[:offset_y] if details[:offset_y]
		@z 			= details[:z] 		 if details[:z]
		@angle 		= details[:angle] 	 if details[:angle]

		@offset_x ||= 0
		@offset_y ||= 0
		@z ||= 0
		@angle ||= 0

		@centre_point = [@x * @size + @size / 2, @y * @size + @size / 2]
	end

	def draw
		if @details[:connected] || @details[:orientated]
			draw_rot
		else
			@image.draw @x * @size + @offset_x, @y * @size + @offset_y, @z
		end
	end

	def draw_rot
		@image.draw_rot @centre_point[0], @centre_point[1], @z, @angle
	end
end

module ZOrder
  TILE, TOWER = *(0..100)
end


class GameWindow < Gosu::Window
	def initialize
		#:type parameter will determine key for images hash if :connected is not true.
		#optional params for symbol_details are:
		symbol_details = {
			'#' => {type: 'road', connected: true, z: ZOrder::TILE},
			'G' => {type: 'garage', orientated: true},
			'T' => {type: 'tower', z: ZOrder::TOWER, offset_y: -10},
			'.' => {type: 'background'},
		}

		image_path = "assets/images/"
		images = {
			block: 		image_path + 'background.bmp', 
			straight: 	image_path + 'straight_road.bmp',
			corner: 	image_path + 'corner_junction.bmp',
			tri: 		image_path + 'tri_junction.bmp',
			quad: 		image_path + 'quad_junction.bmp',

			garage: 	image_path + 'garage.bmp',
			tower: 		image_path + 'tower_block.bmp',
			background: image_path + 'background.bmp'
		}

		@grid = Gridmap.new("assets/roadmap.txt", symbol_details, 30)
		super(@grid.pixel_width, @grid.pixel_height, fullscreen = false)
		@grid.define_tiles(self, images)
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
	    	self.caption = @grid.find_tile(mouse_x, mouse_y).inspect
	    end
  	end
end

controller = GameWindow.new
controller.show