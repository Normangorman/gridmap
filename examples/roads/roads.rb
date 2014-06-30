require 'gosu' 
require 'gridmap'

module ZOrder
  TILE, TOWER = *(0..100)
end

class GameWindow < Gosu::Window
	def initialize
		super(1000, 1000, fullscreen = false)
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
			buffer: 	image_path + 'straight_road.bmp',
			block: 		image_path + 'background.bmp',
			straight: 	image_path + 'straight_road.bmp',
			corner: 	image_path + 'corner_junction.bmp',
			tri: 		image_path + 'tri_junction.bmp',
			quad: 		image_path + 'quad_junction.bmp',

			garage: 	image_path + 'garage.bmp',
			tower: 		image_path + 'tower_block.bmp',
			background: image_path + 'background.bmp'
		}

		@grid = Gridmap.new(self, "assets/roadmap.txt", symbol_details, images, 30)
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