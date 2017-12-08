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

  ROW, COL = [0,1]

  def initialize(width, height)
    @width = width
    @height = height
    @cells = self.initialize_field(@width, @height)

    @positions = {
      me: nil,
      opponent: nil,
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
    @positions = {
      enemies: Array.new,
      snippets: Array.new,
      bombs: Array.new,
      ticking_bombs: Array.new
    }
  end

  def clear_positions
    @positions = {
      me: nil,
      opponent: nil,
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
    self.positions()    
	end

	def parse_from_string(input)
    clear_array_positions()

    new_cells = input.split(",")
    x = 0
    y = 0

    new_cells.each do |cellString| 
      @cells[x][y] = cellString

      cellParts = cellString.split(";")

      cellParts.each do |cellPart|
        case cellPart[0]
        when S_PLAYER
          if cellPart.eql? @strings[:me]
            @positions[:me] = [x,y]
          else
            @positions[:opponent] = [x,y]
          end
        when S_SNIPPET
          @positions[:snippets] << [x,y]
        when S_GATE
          if @positions[:left_gate].nil? || @positions[:right_gate].nil?
            if cellPart.eql? @strings[:left_gate]
              @positions[:left_gate] = [x,y]
            elsif cellPart.eql? @strings[:right_gate]
              @positions[:right_gate] = [x,y]
            end
          end
        end
      end # End looping through cellParts

      # Increment to next cell
      x += 1
      if x == @width
        x = 0
        y += 1
      end
    end # End looping through cellString
  end

  def valid_move?(start,move)
    delta = DIRECTIONS[move]
    check_cell = [start[ROW] + delta[ROW],
                  start[COL] + delta[COL]]
    begin
      return @cells[check_cell[ROW]][check_cell[COL]] != S_BLOCKED
    rescue NoMethodError
      return false # This cell doesn't exist, so not a valid move
    end
  end

  def valid_move_for_me?(move)
    self.valid_move?(@positions[:me],move)
  end

  def valid_moves(start)
    # Check if Gate
    if start == @positions[:left_gate]
      return ['left']
    elsif start == @positions[:right_gate]
      return ['right']
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
    dir_string = DIRECTIONS.key([x,y])
    return dir_string
  end

  def move_me_in_direction(target_pos)
    move_direction(@positions[:me], target_pos)
  end

end

