# Ensure we're using the latest columns for each model
Rails.application.eager_load! # Make sure all models are loaded
ActiveRecord::Base.descendants.each do |c|
  c.reset_column_information  # Reload column names from database
end

#SeedFu.seed(fixture_paths, filter) # Both argumants optional - github.com/mbleigh/seed-fu
