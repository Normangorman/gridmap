require 'gosu' 

class Gridmap < Array
	attr_reader :tile_size, :grid_width, :grid_height, :pixel_width, :pixel_height, :connected_tiles, :orientated_tiles
  	def initialize(window, map_path, symbol_details, images, tile_size)
  		@window 			= window
  		@map_path 			= map_path
  		@symbol_details		= symbol_details
  		@images 			= images
  		@tile_size 			= tile_size

  		make_map
  		define_tiles
	end

	def make_map
		@connected_tiles 	= []
  		@orientated_tiles 	= []
		IO.readlines(@map_path).each_with_index do |line, y|
	      	gridline = []
	      	line.chomp.split("").each_with_index do |symbol, x|
	      		t = Tile.new(x, y, @tile_size, @symbol_details[symbol])
	      		gridline 			<< t
	      		@connected_tiles 	<< t if t.details[:connected]
	      		@orientated_tiles 	<< t if t.details[:orientated]
	     	end
	      	self << gridline
	    end

	    #Checks to make sure all lines are the same length.
	    line_count = self.first.count
	    self.each {|line| if line.count != line_count
	    						raise StandardError, "The lines in your map file are not all the same length." end}

	    #Since all lines should contain the same number of characters, the width is set by counting the number of characters in the first line.
		@grid_width  = self.first.count - 1
		@grid_height = self.count - 1

		@pixel_width = (@grid_width + 1) * @tile_size
		@pixel_height = (@grid_height + 1) * @tile_size
	end

	def define_tiles
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
				img_key = :buffer
				for n in 0..3
					tile.angle = 180 + 90 * n if tile.connections[n] == true
				end
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

			if @images[img_key] == nil
				raise StandardError, "Oops, an image was not found for the key: #{img_key}."
			end
			tile.image = Gosu::Image.new(@window, @images[img_key], true)
		end

		angle_orientated_tiles

		#Sets image for all non-connected tiles.
		self.each do |line|
			line.each do |tile|
				unless tile.details[:connected]
					#img_key is inferred from the tile's type!
					img_key = tile.details[:type].to_sym
					tile.image = Gosu::Image.new(@window, @images[img_key], true)
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

	def change_level(new_map, *p)
		puts "changing level"
		#Clears the current grid
		self.count.times { self.pop }

		@map_path = new_map
		#Replaces instance variables with param variables if they exist.
		@symbol_details = p[0] if p[0]
		@images 		= p[1] if p[1]
		@tile_size		= p[2] if p[2]

		make_map
  		define_tiles
	end
end

class Tile
	attr_reader :x, :y, :pixel_x, :pixel_y, :centre_point
	attr_accessor :angle, :details, :image, :z, :connections
	def initialize(x, y, size, details)
		@x, @y, @size, @details = x, y, size, details
		@pixel_x 	= @x * size
		@pixel_y 	= @y * size
		
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
