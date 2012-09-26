Delayed::Worker.max_attempts = 5
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.default_priority  = 5
Delayed::Worker.sleep_delay = 15
