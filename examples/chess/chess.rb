require 'gosu' 
require 'gridmap'

class GameWindow < Gosu::Window
	def initialize
		super(300, 300, fullscreen = false)
		#:type parameter will determine key for images hash if :connected is not true.
		#optional params for symbol_details are:
		symbol_details = {
			'#' => {type: 'border', connected: true},
			'w' => {type: 'white'},
			'b' => {type: 'black'},
		}

		image_path = "assets/images/"
		images = {
			straight: 	'assets/images/straight_border.bmp',
			corner: 	'assets/images/corner_border.bmp',

			black:    	'assets/images/black_square.bmp',
			white:      'assets/images/white_square.bmp',
		}
		#window, map_path, symbol_details, images, tile_size
		@grid = Gridmap.new(self, "assets/chessboard.txt", symbol_details, images, 30)
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
	    	@grid.change_level("assets/chessboard2.txt")
	    end
  	end
end

controller = GameWindow.new
controller.show