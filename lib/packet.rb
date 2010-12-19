require 'writer.rb'

module BinaryProcessor

  class Packet 
  
    attr_reader   :name
    attr_reader   :params

    def self.type(name, &block)
      return new(name, &block)
    end

    def self.process(packet, types)
      @@bundle = types
      parser = @@schemas[@@bundle.pop]
      parser.process packet
    end
    
    def initialize(name, &block)
      @@schemas ||= {}
      @@schemas[name] = self
      @name = name
      @offset = 0
      @values = {}
      @stream = Stream.new
      @proc = block
    end  
  
    def method_missing(m, *args, &block)
      if (m.to_s =~ /\?$/)
        return @values[m.to_s[0, m.to_s.size-1].to_sym]
      else
        self.send :parse, m, args, &block
      end
    end
  
    def params=(params)
      @params = {}
      params.each do |value|
        if (value.kind_of? Hash)
          @params[value.keys[0]] = value[value.keys[0]]
        else
          @params[value] = true
        end
      end
      
      @params[:base] = 16
      @params[:base] = 2  if @params.include?(:binary)
      @params[:base] = 10 if @params.include?(:decimal)
    end
  
    def parse(name, *args, &block)
      @element = name.to_s
      padding = args[0].shift
      self.params = args[0]
      
      value = @stream.read(padding)
      @values[name] = value

      base = params[:base]
    
      if (block)
        
        # Evaluate the possible values
        values = {}
        block.call(values)
        
        if params.include?(:flags)
          flags = []

          values.each do |key, flag|
            flags << flag if (key & value) > 0
          end

          Writer.instance << "#{@element}: #{flags.join(", ")} [0x#{value.to_s(params[:base])}]"
        else
          Writer.instance << "#{@element}: #{values[value]} [0x#{value.to_s(params[:base])}]"
        end
      else
        Writer.instance << "#{@element}: #{value.to_s(base)}"
      end
    end  

    def process(stream)
      Writer.instance << "#{@name} { "
      Writer.instance.enter

      @stream << stream
      @proc.call(self)

      Writer.instance.leave
      Writer.instance << "}"
    end
  end
end