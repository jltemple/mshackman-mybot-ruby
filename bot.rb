require_relative 'player'
require_relative 'game'

module Bot

	def self.move(game)

		# TODO: Get actual valid moves
		valid_moves = game.field.valid_moves_for_me
    
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

	def self.attack(direction, ticks)
		return direction << ";drop_bomb " << ticks.to_s
	end

end