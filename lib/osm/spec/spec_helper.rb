require 'fakeweb'
require 'httparty'
require 'active_support'

require 'osm'

FakeWeb.allow_net_connect = false


RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.before(:each) do
    FakeWeb.clean_registry
    Rails.cache.clear
  end
end


module Rails
  def self.cache
    @cache ||= Cache.new
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
    def initialize
      @cache = {}
    end
    def write(key, data, options={})
      @cache[key] = data
    end
    def read(key)
      @cache[key]
    end
    def exist?(key)
      @cache.include?(key)
    end
    def clear
      @cache = {}
    end
  end
end
