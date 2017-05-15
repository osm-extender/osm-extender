class StatusController < ApplicationController
  before_action { require_osmx_permission :view_status }

  def index
    pid_file = defined?(Unicorn) ? 'unicorn.pid' : 'server.pid'
    pid_file = File.join(Rails.root, 'tmp', 'pids', pid_file)
    @unicorn_workers = `pgrep -cP #{IO.read(pid_file)}`

    @sessions = {
      total: Session.count,
    }
  end

end
