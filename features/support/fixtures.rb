# Ensure fixtures are loaded
# This needs to be done only once as cucumber uses a database transaction for each test

ActiveRecord::Fixtures.reset_cache
fixtures_folder = File.join(Rails.root, 'test', 'fixtures')
fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
ActiveRecord::Fixtures.create_fixtures(fixtures_folder, fixtures)
