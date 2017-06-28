describe Session do

  it '#delete_old_sessions' do
    Timecop.freeze(DateTime.new(2016, 10, 7, 23, 00))
    expect(Rails).to receive_message_chain(:application, :config, :sorcery, :session_timeout){ 60.minutes }
    expect(Session).to receive(:destroy_all).with(['updated_at < ?', '2016-10-07 22:00:00']).and_return(true)
    described_class.delete_old_sessions()
  end

end
