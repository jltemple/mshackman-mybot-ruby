class Player
	attr_accessor :name, :snippets, :bombs, :row, :col

	def initialize(name)
		@name = name
	    @snippets = 0
	    @bombs = 0
	    @row = 0
	    @col = 0
	end
end