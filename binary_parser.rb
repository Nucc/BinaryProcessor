path = "#{File.dirname(__FILE__)}/lib"
if File.directory?(path)
  $:.unshift path
end

require 'packet.rb'
require 'stream.rb'
require 'extensions.rb'