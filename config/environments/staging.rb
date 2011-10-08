SectionManagementSystem::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Expands the lines which load the assets
  config.assets.debug = true

  config.log_level = :debug
end
