if Figaro.env.stop_on_first_failure?
  After do |scenario|
    Cucumber.wants_to_quit = true if scenario.failed?
  end
end
