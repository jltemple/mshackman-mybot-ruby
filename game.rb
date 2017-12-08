require_relative 'player'
require_relative 'field'
require_relative 'bot'

class Game
  attr_reader :settings, :players, :field

  SETTINGS_MAPPINGS = {
    "timebank" => :initial_timebank,
    "time_per_move" => :time_per_move,
    "player_names" => :player_names,
    "your_bot" => :my_bot,
    "your_botid" => :my_botid,
    "field_width" => :field_width,
    "field_height" => :field_height,
    "max_rounds" => :max_rounds,
    "character" => :character
  }

  def initialize(character)
    @settings = {
      initial_timebank: 0,
      time_per_move: 10,
      player_names: [],
      my_bot: nil,
      my_botid: -1,
      field_width: 0,
      field_height: 0,
      max_rounds: 0,
      character: character
    }

    @field = nil
    @round = 0
    @last_update = 0
    @last_timebank = 0
    @players = nil
  end

  def set_settings(command, value)
    case command
    when "player_names" 
      # Split and set any array values
      @settings[:player_names] = value.split(',')
      first_name = @settings[:player_names][0]
      second_name = @settings[:player_names][1]
      @players = {
        first_name => Player.new(first_name),
        second_name => Player.new(second_name)
      }
    when "your_bot" 
      # Set any string values
      @settings[SETTINGS_MAPPINGS[command]] = value
    when "timebank", "time_per_move", "your_botid", "field_width", "field_height", "max_rounds" 
      # Cast and set any integer values
      @settings[SETTINGS_MAPPINGS[command]] = value.to_i
    end # Ending setting the setting
  end

  def update(target, command, value)
    case target
    when "game"

      case command
      when "round"
        @round = value.to_i
      when "field"
        if @field.nil?
          @field = Field.new(@settings[:field_width], @settings[:field_height])
          @field.set_player_string(@settings[:my_botid])
        end
        @field.parse_from_string(value)
      end # End cases for "game"

    when *@settings[:player_names]
      case command
      when "snippets"
        @players[target].snippets = value.to_i
      when "bombs"
        @players[target].bombs = value.to_i
      end
    end # End of update player
  end

  def action(command, value)
    case command
    when "character"
      puts @settings[:character]
    when "move"
      puts Bot.move(self)
    end
  end

  def run
    not_finished=true

    while not_finished

      line = gets
      if line != nil
        line.chomp!
      else
        next
      end

      # Split the input string by commas and call the proper method
      command_parts = line.split()
      key = command_parts[0]
      case key
      when "settings"
        self.set_settings(command_parts[1],command_parts[2])
      when "update"
        self.update(command_parts[1],command_parts[2], command_parts[3])
      when "action"
        self.action(command_parts[1],command_parts[2])
      else 
        puts "Invalid command"
      end
    end

  end # End of run

end
