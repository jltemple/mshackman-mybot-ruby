require_relative 'player'
require_relative 'game'
require_relative 'field'
require_relative 'node'
require_relative 'graph'

require 'pp'

class Bot

  ROW, COL = [0,1]


  def initialize(field)
    @graph = Graph.new(field.width,field.height)
    @field = field
    set_obstacles()
  end

  # Well I mean the graph is static so I can ei
  def set_obstacles
    @field.cells.each_with_index do |column, x| 
      column.each_with_index do |cellString, y|
        if cellString.include? 'x'
          @graph.set_obstacle(x,y)
        end
      end
    end
  end

  def test_graph()
    pp @graph.shortest_path(0,2,6,3)
  end

  def shortest_path(start_pos, end_pos)
    @graph.shortest_path(start_pos[ROW],start_pos[COL], end_pos[ROW], end_pos[COL])
  end

  def closest_snippet_path()
    snippet_paths = Array.new
    my_pos = @field.positions[:me]
    pp @field.positions[:snippets]
    @field.positions[:snippets].each do |snippet_pos|
      snippet_paths << shortest_path(my_pos,snippet_pos)
    end
    pp snippet_paths
  end

	def move(game)

		# TODO: Get actual valid moves
		valid_moves = game.field.valid_moves_for_me

    closest_snippet_path()
    
    # Pass when no valid moves
    if (valid_moves.size <= 0) 
        return "pass"
    end

    random_move = valid_moves[Random.rand(valid_moves.size)]

   	# Get my player from the game
    me = game.players[game.settings[:my_bot]]

    # Just return random move if no bombs
    if (me.bombs <= 0) 
      return random_move
    end

    # Get random number of bomb ticks
    ticks = Random.rand(4) + 2 # Random number from 2 to 5

    return attack(random_move, ticks)
	end

	def attack(direction, ticks)
		return direction << ";drop_bomb " << ticks.to_s
	end

end