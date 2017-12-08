# From https://gist.github.com/mburst/5024462

require_relative 'priority_queue'
require 'set'

class Graph
	def initialize(width, height)
		@height = height-1 # Last index in 0 based array
		@width = width-1
		@grid = []
		for y in 0..@height
		  row = []
		  for x in 0..@width
			row.push(Node.new(x, y))
		  end
		  @grid.push(row)
		end
	end
  
	def set_obstacle(x, y)
		@grid[y][x].set_obstacle()
	end
	
	def shortest_path(start_x, start_y, finish_x, finish_y)

		def heuristic(current, target)
			return [(current.x - target.x).abs, (current.y - target.y).abs].max
		end
		
		start = @grid[start_y][start_x]
		finish = @grid[finish_y][finish_x]
		
		visited = Set.new # The set of nodes already evaluated
		previous = {} # Previous node in optimal path from source
		previous[start] = 0
		f_score = PriorityQueue.new
		
		# All possible ways to go in a node
		dx = [1, 0, -1, 0]
		dy = [0, 1, 0, -1]
		
		start.set_g_score(0) # Cost from start along best known path
		f_score[start] = start.g_score + heuristic(start, finish) # Estimated total cost from start to finish
		
		while !f_score.empty?
			current = f_score.delete_min_return_key # Node with smallest f_score
			visited.add(current)
			
			if current == finish
				path = Set.new
				while previous[current]
					path.add(current)
					current = previous[current]
				end

				# return "Path found"
				# Why just print? Give me the path!
				return path
			end
			
			# Examine all directions for the next path to take
			for direction in 0..3
				new_x = current.x + dx[direction]
				new_y = current.y + dy[direction]
				
				if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
					next # Try next configuration
				end
				
				neighbor = @grid[new_y][new_x]
				
				# Check if we've been to a node or if it is an obstacle
				if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
					next
				end
				
				if direction % 2 == 1
					tentative_g_score = current.g_score + 14 # traveled so far + distance to next node diagonal
				else
					tentative_g_score = current.g_score + 10 # traveled so far + distance to next node vertical or horizontal
				end
				
				# If there is a new shortest path update our priority queue (relax)
				if tentative_g_score < neighbor.g_score
					previous[neighbor] =  current
					neighbor.set_g_score(tentative_g_score)
					f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
				end
			end
		end
		
		return "Failed to find path"
	end
	
	def print_path(path)
		for y in 0..@height
			for x in 0..@width
				if @grid[y][x].obstacle
					print "X "
				elsif path.include? @grid[y][x]
					print "- "
				else
					print "0 "
				end
			end
			print "\n"
		end
	end
	
	def to_s
		return @grid.inspect
	end
end