require 'fakeweb'
require 'httparty'
require 'active_support'

require 'osm'

module Rails
  def self.cache
    Cache.new
  end
  def self.env
    Env.new
  end

  class Env
    def development?
      false
    end
  end

  class Cache
    def write(key, data, options={})
      true
    end
    def exist?(key)
      false
    end
  end
end
