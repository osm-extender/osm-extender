describe RedirectWwwMiddleware do

  let(:app) { lambda {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']]} }
  subject { RedirectWwwMiddleware.new app }
#  let(:request) { Rack::MockRequest.new subject }

  context 'request to www.example.com' do
    let(:request) { Rack::MockRequest.env_for("http://www.example.com:8080/path?some=value") }

    it 'Does not pass the request through' do
      expect(app).to_not receive(:call)
      subject.call(request)
    end

    describe 'Response' do
      let(:response) { subject.call(request) }
      it('Has a status of 307 (Temporary Redirect)') { expect(response[0]).to eq 307 }
      it('Have a Location header') { expect(response[1]).to have_key 'Location'}
      it('Which is a text/plain type') { expect(response[1]['Content-Type']).to eq  'text/plain'}
      it('Has a body showing the new url') { expect(response[2][0]).to match /^Please go to\n.+\n$/ }
      it 'Redirects to example.com' do
        expect(response[1]['Location']).to eq 'http://example.com:8080/path?some=value'
        expect(response[2][0]).to match /^.+\nhttp:\/\/example.com:8080\/path\?some=value\n$/
      end
    end
  end

  context 'request to example.com' do
    let(:request) { Rack::MockRequest.env_for("http://example.com:8080/path?some=value") }
    it 'Passes the request through' do
      expect(app).to receive(:call).and_call_original
      response = subject.call(request)
      expect(response).to eq [200, {'Content-Type' => 'text/plain'}, ['OK']]
    end
  end

end
