class DelayedJobController < ApplicationController
  before_action { require_osmx_permission :administer_delayed_job }

  def index
    wanted_settings = [:default_priority, :max_attempts, :max_run_time, :sleep_delay, :destroy_failed_jobs, :delay_jobs]
    @settings = Hash[ wanted_settings.map{ |i| [i, Delayed::Worker.send(i)] } ]
    @jobs = Delayed::Job.all
  end

end
