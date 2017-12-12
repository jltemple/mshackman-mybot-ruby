# Class for the playing field
#
# Some referneces for maze manuevering: https://defuse.ca/blog/ruby-maze-solver.html
#

class Field
  attr_reader :cells, :positions, :width, :height

  S_EMPTY, S_BLOCKED, S_PLAYER, S_BUG_SPAWN, S_GATE, S_BUG, S_BOMB, S_SNIPPET = ['.', 'x', 'P', 'S', 'G', 'E', 'B', 'C']

  DIRECTIONS = {
    "up" => [0,-1],
    "down" =>  [0,1],
    "left" => [-1,0],
    "right" => [1,0]
  }

  BUG_TYPES = {
    chase: 'E0',
    predict: 'E1',
    lever: 'E2',
    far_chase: 'E3'
  }

  ROW, COL = [0,1]

  def initialize(width, height)
    @width = width
    @height = height
    @cells = self.initialize_field(@width, @height)

    @positions = {
      me: nil,
      opponent: nil,
      spawn: nil,
      enemies: Array.new,
      snippets: Array.new,
      bombs: Array.new,
      ticking_bombs: Array.new,
      left_gate: nil,
      right_gate: nil
    }

    @strings = {
      me: '',
      left_gate: S_GATE + 'l',
      right_gate: S_GATE + 'r'
    }
  end

  def initialize_field(width, height)
    Array.new(width){Array.new(height)}
  end

  def set_player_string(my_botid)
    @strings[:me] = S_PLAYER + my_botid.to_s
  end

  def clear_field_cells
    @cells.each do |column| 
      column.each do |cell|
        cell = nil
      end
    end
  end

  def clear_array_positions
    @positions[:enemies] = Array.new
    @positions[:snippets] = Array.new
    @positions[:bombs] = Array.new
    @positions[:ticking_bombs] = Array.new
  end

  def clear_for_new_turn
    clear_array_positions()
    @positions[:spawn] = nil # There isn't always a spawn, this needs to reset
  end

  def clear_positions
    @positions = {
      me: nil,
      opponent: nil,
      spawn: nil,
      enemies: Array.new,
      snippets: Array.new,
      bombs: Array.new,
      ticking_bombs: Array.new,
      left_gate: nil,
      right_gate: nil
    }
  end

  def clear_field
    self.clear_field_cells()
    self.clear_positions()    
	end

	def parse_from_string(input)
    clear_for_new_turn()

    new_cells = input.split(",")
    x = 0
    y = 0

    new_cells.each do |cell_string| 
      @cells[x][y] = cell_string

      cell_parts = cell_string.split(";")

      cell_parts.each do |cell_part|
        case cell_part[0]
        when S_PLAYER
          if cell_part.eql? @strings[:me]
            @positions[:me] = [x,y]
          else
            @positions[:opponent] = [x,y]
          end
        when S_SNIPPET
          @positions[:snippets] << [x,y]
        when S_BUG
          @positions[:enemies] << [x,y]
        when S_BOMB
          # If there's a tick count (second character), it's ticking
          # Otherwise it's to pick up
          if cell_part.length == 1
            @positions[:bombs] << [x,y]
          else
            @positions[:ticking_bombs] << [x,y]
          end
        when S_BUG_SPAWN
          # If there's a swawn count (second character), it's about to spawn
          if cell_part.length > 1
            @positions[:spawn] = [x,y]
          end
        when S_GATE
          if @positions[:left_gate].nil? || @positions[:right_gate].nil?
            if cell_part.eql? @strings[:left_gate]
              @positions[:left_gate] = [x,y]
            elsif cell_part.eql? @strings[:right_gate]
              @positions[:right_gate] = [x,y]
            end
          end
        end
      end # End looping through cell_parts

      # Increment to next cell
      x += 1
      if x == @width
        x = 0
        y += 1
      end
    end # End looping through cell_string
  end

  def valid_move?(start,move)
    delta = DIRECTIONS[move]
    check_cell = [start[ROW] + delta[ROW],
                  start[COL] + delta[COL]]
    begin
      if check_cell[ROW] < 0 || check_cell[COL] < 0
        return false # Ruby accepts negative indexes in arrays
      elsif check_cell[ROW] >= @width || check_cell[COL] >= @height
        return false # Out of range
      elsif @cells[check_cell[ROW]][check_cell[COL]] == S_BLOCKED
        return false
      else
        true
      end
    rescue NoMethodError
      return false # This cell doesn't exist, so not a valid move
    end
  end

  def valid_move_for_me?(move)
    self.valid_move?(@positions[:me],move)
  end

  def valid_moves(start)
    # Check if Gate, can go through or go back
    if start == @positions[:left_gate] || start == @positions[:right_gate]
      return ['left','right']
    end

    # Find valid list
    valid_list = []
    DIRECTIONS.each do |direction,delta|
      if self.valid_move?(start,direction)
        valid_list.push(direction) 
      end
    end
    return valid_list
  end

  def valid_moves_for_me    
    self.valid_moves(@positions[:me])
  end

  def move_direction(start_pos, target_pos)
    x = target_pos[ROW] - start_pos[ROW]
    y = target_pos[COL] - start_pos[COL]
    return DIRECTIONS.key([x,y])
  end

  def move_me_in_direction(target_pos)
    move_direction(@positions[:me], target_pos)
  end

  def type_bug(bug_pos)
    bug_string = @cells[bug_pos[ROW]][bug_pos[COL]]
    bug_cell_parts = bug_string.split(";")
    bug_cell_parts.each do |cell_part|
      if cell_part[0] == 'E'
        return BUG_TYPES.key(cell_part)
      end
    end
  end

end

