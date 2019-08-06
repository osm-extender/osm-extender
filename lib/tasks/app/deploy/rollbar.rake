namespace :app do
  namespace :deploy do
    desc "Post deployment notification to rollbar"
    task :rollbar => :environment do
      unless Figaro.env.rollbar_access_token?
        Rails.logger.error "Can't post deployment to rollbar - rollbar_access_token is not in the environment!"
        next # 'return' from task
      end

      commit = Status.new.commit
      Rails.logger.info "Posting deployment to rollbar for #{commit[:id]} - #{commit[:title].inspect}"

      uri = URI.parse 'https://api.rollbar.com/api/1/deploy/'
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
        access_token: Figaro.env.rollbar_access_token!,
        environment: Rails.env,
        revision: commit[:id],
        comment: commit[:title],
      })
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      response = http.request(request)

      if response.is_a?(Net::HTTPOK)
        depolyment_id = JSON.parse(response.body)&.dig('data', 'deploy_id')
        Rails.logger.info "Sucessfully made deployment in Rollbar#{ " (#{depolyment_id })" if depolyment_id }."
      elsif response.is_a?(Net::HTTPOK)
        Rails.logger.error "Rollbar returned an unexpected body - #{response.body.inspect}"
      else
        Rails.logger.error "Rollbar returned a #{response}."
      end
    end # task rollbar
  end # namespace deploy
end # namespace app
