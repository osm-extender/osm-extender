class DelayedJobController < ApplicationController
  before_action { require_osmx_permission :administer_delayed_job }

  def index
    wanted_settings = [:default_priority, :max_attempts, :max_run_time, :sleep_delay, :destroy_failed_jobs, :delay_jobs]
    @settings = wanted_settings.inject({}) do |hash, value|
      hash[value] = Delayed::Worker.send(value)
      hash
    end

    @jobs = Delayed::Job.all
  end

end
