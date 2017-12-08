require_relative 'player'
require_relative 'game'
require_relative 'field'
require_relative 'node'
require_relative 'graph'

require 'pp'

class Bot

  ROW, COL = [0,1]
  WEIGHTERS = {
    snippet_reward: 1.5,
    enemy_reward: -4.5,
    snippet_exponent: 1.4,
    enemy_exponent: 1.8
  }

  def initialize(field)
    @graph = Graph.new(field.width,field.height)
    @field = field
    set_obstacles()
    set_gates()
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

    # Well I mean the graph is static so I can ei
  def set_gates
    @graph.set_gates( @field.positions[:left_gate][ROW],
                      @field.positions[:left_gate][COL],
                      @field.positions[:right_gate][ROW],
                      @field.positions[:right_gate][COL])
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

  def enemy_paths()
    paths = Array.new
    my_pos = @field.positions[:me]
    @field.positions[:enemies].each do |snippet_pos|
      paths << shortest_path(my_pos,snippet_pos)
    end
    return paths
  end

  def shortest_in_set(paths)
    paths.min_by { |set| set.length }
  end

  def next_space_from_path(path)
    return [path[-2].x,path[-2].y]
  end

  def weight_path(path, reward, strength = WEIGHTERS[:snippet_exponent], method = :inverse_exponent)
    if (path.length == 0)
      return 0
    end
    case method
    when :inverse_exponent
      length_weight = 1.0 / (path.length**strength)
    end
    return (reward * length_weight)
  end

  def weight_all_paths(moves, paths, reward, strength = WEIGHTERS[:snippet_exponent], method = :inverse_exponent)
    paths.each do |path|
      target = next_space_from_path(path)
      if (@field.positions[:me] == @field.positions[:right_gate] && target == @field.positions[:left_gate])
        direction = 'right'
      elsif (@field.positions[:me] == @field.positions[:left_gate] && target == @field.positions[:right_gate])
        direction = 'left'
      else
        direction = @field.move_me_in_direction(target)
      end
      weight = weight_path(path, reward, strength, method)
      moves[direction] = moves[direction] + weight
    end
  end

  def greatest_move(moves)
    return moves.max_by{|direction,weight| weight}[0]
  end

	def move(game)

    valid_moves = game.field.valid_moves_for_me
		
    # No snippets, just jump around for now
    if (@field.positions[:snippets].length <= 0)
      random_move = valid_moves[Random.rand(valid_moves.size)]
      return random_move
    end

    p_snippet_paths = snippet_paths()
    p_enemy_paths = enemy_paths()

    # Create a Hash of the directions that the bot can go
    p_moves = Hash.new
    valid_moves.each {|direction| p_moves[direction] = 0}

    # Get weights of directions for snippets
    # weight_all_paths(p_moves, p_snippet_paths, SNIPPET_REWARD)
    weight_all_paths(p_moves, p_snippet_paths, WEIGHTERS[:snippet_reward], WEIGHTERS[:snippet_exponent])
    weight_all_paths(p_moves, p_enemy_paths, WEIGHTERS[:enemy_reward], WEIGHTERS[:enemy_exponent])

    move = greatest_move(p_moves)
    
    # @graph.print_path(path_to_closest_snippet)

    return move    

    # TODO: Danger zone!
    # When snippets start to trigger a bug entering,
    # Move away from the enter zone ASAP

    # TODO: All the bomb logic
   	# # Get my player from the game
    # me = game.players[game.settings[:my_bot]]

    # TODO: Weight bugs differently based on chase type

    # TODO, don't use gates when checking which way a bug will come

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