require 'gosu'

class Gridmap < Array
	attr_reader :tile_width, :tile_height, :width, :height
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
		@width = self.first.count * tile_width
		@height = self.count * tile_height
	end

	def draw_tiles(window)
		self.each {|line| line.each {|tile| tile.draw(nil, window)}}
	end
end

class Tile
	attr_reader :x, :y, :z
	attr_accessor :details, :image, :image_path
	def initialize(x, y, width, height, details)
		@x, @y, @width, @height, @details = x, y, width, height, details

		if details.is_a?(Hash)
			if details[:image]
				@image = details[:image]
			elsif details[:image_path]
				@image_path = details[:image_path]
			end
		end
	end

	def draw(*p) #p should contain z, then image or window
		unless p.empty?
			process_optional_params(p)
		end
		@z ||= ZOrder::TILE
		@image.draw @x * @width, @y * @height, @z
	end

	def draw_rot(offset_x, offset_y, angle, *p) #p should contain z, then image or window
		offset_x, offset_y, angle = p[0], p[1], p[2]
		unless p.empty?
			process_optional_params(p)
		end
		@z ||= ZOrder::TILE
		@image.draw_rot @x * @width + offset_x, @y * @height + offset_y, @z, angle
	end

	def process_optional_params(p)
		@z = p[0] if p[0] # if p isn't empty, z could still be set as nil.
		
		if p[1]
			if p[1].class == Gosu::Image
				@image = p[1]
			elsif p[1].kind_of?(Gosu::Window)
				#If a window is passed then we assume that the image path has already been set.
				@image = Gosu::Image.new(p[1], @image_path, true)
			else
				raise StandardError, "Image parameter for tile draw method must be an image or a window: #{p[1].inspect}"
			end
		end

	end
end

module ZOrder
  TILE, EXAMPLE = *(0..100)
end


class Controller < Gosu::Window
	def initialize
		symbol_hash = {
			'#' => {type: 'road', image_path: 'assets/images/road.bmp'}
		}
    	symbol_hash.default = 'blank'

		@grid = Gridmap.new("assets/roadmap.txt", symbol_hash, 30, 30)
		
		super(@grid.width, @grid.height, fullscreen = false)

		#@grid.each {|line| line.each {|tile| tile.orientate(@grid)}}

		new_image = Proc.new {|name| Gosu::Image.new(self, "assets/images/#{name}.bmp", true)}
    	@images = {
			background: 	new_image.call('background'),
			straight: 		new_image.call('straight_road'),
			corner: 		new_image.call('corner_junction'),
			tri: 			new_image.call('tri_junction'),
			quad: 			new_image.call('quad_junction'),
		}
	end


	def update
	end

	def draw
		@grid_image ||= record(@grid.width, @grid.height) { @grid.draw_tiles(self)}
		@grid_image.draw 0, 0, 0
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