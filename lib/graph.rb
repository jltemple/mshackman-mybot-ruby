# From https://gist.github.com/mburst/5024462

require_relative 'priority_queue'
require 'set'

class Graph
	def initialize(width, height)
		@height = height-1 # Last index in 0 based array
		@width = width-1
		@grid = []
		@gates = {}
		for y in 0..@height
		  row = []
		  for x in 0..@width
			row.push(Node.new(x, y))
		  end
		  @grid.push(row)
		end
	end

	def reset_grid
		for y in 0..@height
			for x in 0..@width
				if !@grid[y][x].obstacle
					@grid[y][x].set_g_score(Float::INFINITY)
				end
			end
		end
	end
  
	def set_obstacle(x, y)
		@grid[y][x].set_obstacle()
	end

	def set_gates(left_gate_x, left_gate_y, right_gate_x, right_gate_y)
		@gates = {
			left_gate_y: left_gate_y,
			left_gate_x: left_gate_x,
			right_gate_y: right_gate_y,
			right_gate_x: right_gate_x
		}
		@grid[left_gate_y][left_gate_x].gate = 'left'
		@grid[right_gate_y][right_gate_x].gate = 'right'
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
				path = Array.new
				while previous[current]
					path.push(current)
					current = previous[current]
				end

				# The previous code would keep the g scores, reset
				# print_path(path)
				reset_grid()
				# Why just print? Give me the path!
				return path
			end
			
			# Examine all directions for the next path to take
			for direction in 0..3

				# If in a right gate and going right, jump to left gate
				if current.gate == 'right' && direction == 0
					new_x = @gates[:left_gate_x]
					new_y = @gates[:left_gate_y]
				# If in a left gate and going left, jump to right gate	
				elsif current.gate == 'left' && direction == 2
					new_x = @gates[:right_gate_x]
					new_y = @gates[:right_gate_y]
				# Not jumping through a gate, walk like a normal bot
				else
					new_x = current.x + dx[direction]
					new_y = current.y + dy[direction]				
				end
				
				if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
					next # Try next configuration
				end
				
				neighbor = @grid[new_y][new_x]


				
				# Check if we've been to a node or if it is an obstacle
				if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
					next
				end
				
				tentative_g_score = current.g_score + 10 # traveled so far + distance to next node vertical or horizontal
				
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