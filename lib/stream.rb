module BinaryProcessor
  
  class Stream
    
    def initialize(stream = "")
      @offset = 0
      @stream = ""
      self << stream
    end
    
    def read(size)
      offset = @offset
      @offset += size
      return @stream[offset, size].to_i(2)
    end
    
    def <<(value)
      if value.is_a? Array
        value.each do |element|
          @stream += element.to_s(2).rjust(8, "0")
        end

      # TODO: currently it only handles string
      else
        @stream = value
      end
      
    end
    
  end
  
  
end