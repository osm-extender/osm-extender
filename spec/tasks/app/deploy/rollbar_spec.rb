describe 'rake app:deploy:rollbar' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Post to rollbar' do
    context 'With rollbar_access_token' do
      before :each do
        status = double(Status)
        expect(Status).to receive(:new).and_return(status)
        expect(status).to receive(:commit).and_return({id: 'abcdef', title: 'A title.'})

        figaro_env = double(Figaro::ENV)
        allow(Figaro).to receive(:env).and_return(figaro_env)
        expect(figaro_env).to receive(:rollbar_access_token?).and_return(true)
        expect(figaro_env).to receive(:rollbar_access_token!).and_return('token')
      end

      it 'Sucessfully' do
        request = double(Net::HTTP::Post)
        http = double(Net::HTTP)
        response = double(Net::HTTPOK)
        expect(Net::HTTP::Post).to receive(:new).with('/api/1/deploy/').and_return(request)
        expect(request).to receive(:set_form_data).with({access_token: 'token', environment: 'test', revision: 'abcdef', comment: 'A title.'})
        expect(Net::HTTP).to receive(:new).with('api.rollbar.com', 443).and_return(http)
        expect(http).to receive(:use_ssl=).with(true)
        expect(http).to receive(:request).with(request).and_return(response)
        expect(response).to receive(:is_a?).with(Net::HTTPOK).and_return(true)
        expect(response).to receive(:body).and_return('{"data": {}}')

        expect { task.execute }.not_to raise_error
      end

      describe 'Unsuccessfully' do
        it 'Not a 200 OK' do
          request = double(Net::HTTP::Post)
          http = double(Net::HTTP)
          response = double(Net::HTTPNotFound)
          expect(Net::HTTP::Post).to receive(:new).with('/api/1/deploy/').and_return(request)
          expect(request).to receive(:set_form_data).with({access_token: 'token', environment: 'test', revision: 'abcdef', comment: 'A title.'})
          expect(Net::HTTP).to receive(:new).with('api.rollbar.com', 443).and_return(http)
          expect(http).to receive(:use_ssl=).with(true)
          expect(http).to receive(:request).with(request).and_return(response)
          expect(response).to receive(:is_a?).with(Net::HTTPOK).and_return(false).twice

          expect { task.execute }.not_to raise_error
        end

        it 'Bad body' do
           request = double(Net::HTTP::Post)
          http = double(Net::HTTP)
          response = double(Net::HTTPOK)
          expect(Net::HTTP::Post).to receive(:new).with('/api/1/deploy/').and_return(request)
          expect(request).to receive(:set_form_data).with({access_token: 'token', environment: 'test', revision: 'abcdef', comment: 'A title.'})
          expect(Net::HTTP).to receive(:new).with('api.rollbar.com', 443).and_return(http)
          expect(http).to receive(:use_ssl=).with(true)
          expect(http).to receive(:request).with(request).and_return(response)
          expect(response).to receive(:is_a?).with(Net::HTTPOK).and_return(true).twice
          expect(response).to receive(:body).and_return('').twice

          expect { task.execute }.not_to raise_error
       end
      end # describe Unsuccessfully

    end # context With rollbar_access_token

    it 'No rollbar_access_token' do
      figaro_env = double(Figaro::ENV)
      allow(Figaro).to receive(:env).and_return(figaro_env)
      expect(figaro_env).to receive(:rollbar_access_token?).and_return(false)
      expect(figaro_env).to_not receive(:rollbar_access_token!)
      expect(Net::HTTP::Post).to_not receive(:new)

      expect { task.execute }.not_to raise_error
    end

  end # describe Post to tollbar
end




        #
        #uri = URI.parse 'https://api.rollbar.com/api/1/deploy/'
        #request = Net::HTTP::Post.new(uri.request_uri)
        #request.set_form_data({
        #  access_token: Figaro.env.rollbar_access_token!,
        #  environment: Rails.env,
        #  revision: commit[:id],
        #  comment: commit[:title],
        #})
        #http = Net::HTTP.new(uri.hostname, uri.port)
        #http.use_ssl = true
        #response = http.request(request)
        #Rails.logger.debug "Rollbar said: #{response.body.inspect}"
        #
        #if response.body.eql?('{"data": {}}')