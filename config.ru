# This file is used by Rack-based servers to start the application.


if defined?(Unicorn)
  # Unicorn self-process killer
  require 'unicorn/worker_killer'
  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, 1024, 2048
  # Max memory size (RSS) per worker (64 - 128 MB)
  use Unicorn::WorkerKiller::Oom, (64*(1024**2)), (128*(1024**2))
end


require ::File.expand_path('../config/environment',  __FILE__)

map Rails.application.routes.default_url_options[:script_name] || '/' do
  run OSMExtender::Application
end
