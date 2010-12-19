require 'singleton'

module BinaryProcessor

  class Writer
  
    include Singleton
  
    attr :tab
  
    def initialize
      @tab = 0
    end
  
    def <<(text)
      @tab.times do
        print "  "
      end
      puts text.to_s
    end
  
    def enter
      @tab += 1
    end
  
    def leave 
      @tab -= 1
    end
  end

end