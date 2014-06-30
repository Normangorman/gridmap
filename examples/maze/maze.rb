require 'gosu'
require 'gridmap'

class GameWindow < Gosu::Window
	def initialize
		super(1500, 900, fullscreen = false)
		#:type parameter will determine key for images hash if :connected is not true.
		#optional params for symbol_details are:
		symbol_details = {
			'+' => {type: 'wall', connected: true},
			' ' => {type: 'path'}
		}

		image_path = "assets/images/"
		images = {
			buffer: 	image_path + 'buffer_wall.bmp',
			straight: 	image_path + 'straight_wall.bmp',
			corner: 	image_path + 'corner_wall.bmp',
			tri:        image_path + 'tri_wall.bmp',
			quad:       image_path + 'quad_wall.bmp', 

			path:       image_path + 'path.bmp',
		}

		@grid = Gridmap.new(self, "assets/maze.txt", symbol_details, images, 20)
		
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