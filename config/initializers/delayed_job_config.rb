Delayed::Worker.delay_jobs = !Rails.env.test? && !Rails.env.cucumber?
Delayed::Worker.default_priority  = 5
Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 15
