class DelayedJobController < ApplicationController
  before_action { require_osmx_permission :administer_delayed_job }

  def index
    wanted_settings = [:default_priority, :max_attempts, :max_run_time, :sleep_delay, :destroy_failed_jobs, :delay_jobs]
    @settings = Hash[ wanted_settings.map{ |i| [i, Delayed::Worker.send(i)] } ]
    @crons = Delayed::Job.where.not(cron: nil)
    @jobs = Delayed::Job.where(cron: nil)
  end

  def show
    @job = Delayed::Job.find(params[:id])
    @handler = YAML::load @job.handler
    @default_priority = Delayed::Worker.default_priority
  end

  def destroy
    Delayed::Job.destroy(params[:id])
    redirect_to delayed_jobs_path
  end
end
