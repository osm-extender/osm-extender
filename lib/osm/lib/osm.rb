require 'osm/version'
Dir[File.join(File.dirname(__FILE__) , 'osm', '*.rb')].each {|file| require file }
