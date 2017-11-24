RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  require File.join(Rails.root, 'spec', 'factories')
end
