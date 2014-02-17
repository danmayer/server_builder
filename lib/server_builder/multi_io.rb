# http://stackoverflow.com/questions/6407141/how-can-i-have-ruby-logger-log-output-to-stdout-as-well-as-file
module ServerBuilder
  class MultiIO
    def initialize(*targets)
      @targets = targets
    end
    
    def write(*args)
      @targets.each {|t| t.write(*args)}
    end
    
    def close
      @targets.each(&:close)
    end
  end
end
