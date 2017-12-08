# From https://gist.github.com/mburst/5024462

class Node
    attr_accessor :gate

    def initialize(x, y)
        @x = x
        @y = y
        @obstacle = false
        @gate = false
        @g_score = Float::INFINITY
    end
    
    def x()
        return @x
    end
    
    def y()
        return @y
    end
    
    def set_obstacle()
        @obstacle = true
    end

    def obstacle()
        return @obstacle
    end

    def set_g_score(score)
        @g_score = score
    end
    
    def g_score()
        return @g_score
    end
    
    def to_s
        return "(" + @x.to_s + ", " + @y.to_s + ", " + @obstacle.to_s + ")"
    end
end