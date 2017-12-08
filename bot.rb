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

  def snippet_paths()
    paths = Array.new
    my_pos = @field.positions[:me]
    @field.positions[:snippets].each do |snippet_pos|
      paths << shortest_path(my_pos,snippet_pos)
    end
    return paths
  end

  def shortest_in_set(paths)
    paths.min_by { |set| set.length }
  end

  def next_space_from_set(set)
    return [set[-2].x,set[-2].y]
  end

	def move(game)

		valid_moves = game.field.valid_moves_for_me

    # Pass when no valid moves
    if (valid_moves.size <= 0) 
      return "pass"
    end

    random_move = valid_moves[Random.rand(valid_moves.size)]

    # No snippets, just jump around for now
    if (@field.positions[:snippets].length <= 0)
      return random_move
    end

    possible_snippet_paths = snippet_paths()
    path_to_closest_snippet = shortest_in_set(possible_snippet_paths)
    to_snippet = next_space_from_set(path_to_closest_snippet)
    move = @field.move_me_in_direction(to_snippet)
    
    # @graph.print_path(path_to_closest_snippet)

    return move    

    # TODO: All the bomb logic
   	# # Get my player from the game
    # me = game.players[game.settings[:my_bot]]

    # # Just return random move if no bombs
    # if (me.bombs <= 0) 
    #   return random_move
    # end

    # # Get random number of bomb ticks
    # ticks = Random.rand(4) + 2 # Random number from 2 to 5

    # return attack(random_move, ticks)
	end

	def attack(direction, ticks)
		return direction << ";drop_bomb " << ticks.to_s
	end

end