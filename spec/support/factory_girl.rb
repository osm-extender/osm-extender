RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  require File.join(Rails.root, 'spec', 'factories')
end
