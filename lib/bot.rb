require_relative 'player'
require_relative 'game'
require_relative 'field'
require_relative 'node'
require_relative 'graph'

require 'pp'

class Bot

  ROW, COL = [0,1]

  # WEIGHTERS EXPLANATION
  # Graphs of weights: http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIyKjEvKHheMS42KSIsImNvbG9yIjoiIzQ0QjM1RSJ9LHsidHlwZSI6MCwiZXEiOiI1KjEvKHheMS42KSIsImNvbG9yIjoiI0JBMUUxRSJ9LHsidHlwZSI6MCwiZXEiOiIyLyh4XjIpIiwiY29sb3IiOiIjOTlCOUZGIn0seyJ0eXBlIjowLCJlcSI6IjcqMS8oeF4xLjgpIiwiY29sb3IiOiIjRkYwMEY3In0seyJ0eXBlIjoxMDAwLCJ3aW5kb3ciOlsiLTcuMTE5OTk5OTk5OTk5OTk4IiwiNS44ODAwMDAwMDAwMDAwMDIiLCItMS42OTk5OTk5OTk5OTk5OTQiLCI2LjMwMDAwMDAwMDAwMDAwNCJdfV0-
  # Snippets: Snippets are all over, and the goal, they should level out slower- the more in a direction, the more we want to go there
  # Bugs:     Bugs are dangerous, try to stay from every getting close, they should always persuade the direction
  # Bombs:    For now, mines are just a nice surprise, if ones around, grab it, but don't change course on the other side of the field
  # Spawns:   They are dangerous if they're close, when we're 1 to 4 spaces away from it, weight it way more than a bug- no surprises! 
  #             Then if we're further from it, treat it less than a bug, a bug will soon come.
  WEIGHTERS = {
    snippet_reward: 2,
    enemy_reward: -5,
    bomb_reward: 2,
    spawn_reward: -7,
    snippet_exponent: 1.6,
    enemy_exponent: 1.6,
    bomb_exponent: 2,
    spawn_exponent: 1.8
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

  def set_gates
    @graph.set_gates( @field.positions[:left_gate][ROW],
                      @field.positions[:left_gate][COL],
                      @field.positions[:right_gate][ROW],
                      @field.positions[:right_gate][COL])
  end

  def test_graph()
    pp @graph.shortest_path(0,2,6,3)
  end

  def shortest_path(start_pos, end_pos, with_gates = true)
    @graph.shortest_path(start_pos[ROW],start_pos[COL], end_pos[ROW], end_pos[COL])
  end

  def snippet_paths(my_pos)
    paths = Array.new
    @field.positions[:snippets].each do |snippet_pos|
      paths << shortest_path(my_pos,snippet_pos)
    end
    return paths
  end

  def enemy_paths(my_pos)
    paths = Array.new
    @field.positions[:enemies].each do |enemy_pos|
      case @field.type_bug(enemy_pos)
      when :predict
        # Ignore the predict bug unless he's on top of player
        predict_path = shortest_path(my_pos,enemy_pos, false)
        paths << predict_path if predict_path.length < 8
      else
        paths << shortest_path(my_pos,enemy_pos, false)
      end
    end
    return paths
  end

  def bomb_paths(my_pos)
    paths = Array.new
    @field.positions[:bombs].each do |bomb_pos|
      paths << shortest_path(my_pos,bomb_pos)
    end
    return paths
  end

  def spawn_paths(my_pos)
    paths = Array.new # Even though it's one path, later methods want an array
    if !@field.positions[:spawn].nil?
      paths << shortest_path(my_pos,@field.positions[:spawn])
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
    if (paths.length == 0)
      return 0
    end
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

  def attack(direction, ticks)
    return direction << ";drop_bomb " << ticks.to_s
  end

	def move(game)

    valid_moves = game.field.valid_moves_for_me
		
    # No snippets, just jump around for now
    if (@field.positions[:snippets].length <= 0)
      random_move = valid_moves[Random.rand(valid_moves.size)]
      return random_move
    end

    my_pos = @field.positions[:me]

    p_snippet_paths = snippet_paths(my_pos)
    p_enemy_paths = enemy_paths(my_pos)
    p_bomb_paths = bomb_paths(my_pos)
    p_spawn_paths = spawn_paths(my_pos)

    # Create a Hash of the directions that the bot can go
    p_moves = Hash.new
    valid_moves.each {|direction| p_moves[direction] = 0}

    # Get weights of directions for snippets
    # weight_all_paths(p_moves, p_snippet_paths, SNIPPET_REWARD)
    weight_all_paths(p_moves, p_snippet_paths, WEIGHTERS[:snippet_reward], WEIGHTERS[:snippet_exponent])
    weight_all_paths(p_moves, p_enemy_paths, WEIGHTERS[:enemy_reward], WEIGHTERS[:enemy_exponent])
    weight_all_paths(p_moves, p_bomb_paths, WEIGHTERS[:bomb_reward], WEIGHTERS[:bomb_exponent])
    weight_all_paths(p_moves, p_spawn_paths, WEIGHTERS[:spawn_reward], WEIGHTERS[:spawn_exponent])


    move = greatest_move(p_moves)
    
    # @graph.print_path(path_to_closest_snippet)

    return move    

    #
    # TODO: ALL BOMB LOGIC 
    #
    # TODO: Ticking!
    # If in column and row of ticking mine
    #   If distance_from_safety <= ticks
    #     Escape!
    #   Else doesn't matter, getting hit anyway, continue like normal
    #
    # TODO- Defense
   	#  If my snippets >= 5 
    #    If opponent and I are in same row or column AND theres no wall between us
    #      If opponent_distance_from_safety > 2
    #        If opponent_snippets < 5
    #          Drop for (opponent_distance_from_safety - 1)
    #        If opponent_distance_from_safety > distance_from_safety
    #          Drop (opponent_distance_from_safety - 1), escape to safety (distance_from_safety)!
    #  Elsif my_snippets < 5 & opponents_snippts >=5 )
    #    If opponent_distance_from_safety > distance_from_safety    
    #      Escape!
    #

    #
    # TODO: ADDITIONAL BUG LOGIC
    #
    # TODO: Weight bugs differently based on chase type
    #

    # TODO: HAIL MARY
    # Hail Mary play, if the opponent is winning and the game is about to wrap up,
    # Let a mine hit us both and hope I can gather up more of their dropped snippets
    #
    # If game round is 220 or 230
    #   If my_snippets >= 5 and opponent_snippets > my_snippets
    #     If opponent and I are in same row or column AND theres no wall between us
    #       If opponent_distance_from_safety > 2
    #         If opponent_snippets < 5
    #           Drop for (opponent_distance_from_safety - 1)    

	end

end