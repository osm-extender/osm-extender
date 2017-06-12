describe Session do

  describe '#delete_old_sessions' do

    it 'Given nothing' do
      Timecop.freeze(DateTime.new(2016, 10, 7, 23, 00))
      expect(Session).to receive(:destroy_all).with(['updated_at < ? OR created_at < ?', '2016-10-07 22:00:00', '2016-10-07 17:00:00']).and_return(true)
      described_class.delete_old_sessions()
    end

    it 'Given numbers' do
      Timecop.freeze(DateTime.new(2016, 10, 7, 23, 00))
      expect(Session).to receive(:destroy_all).with(['updated_at < ? OR created_at < ?', '2016-10-07 21:00:00', '2016-10-06 23:00:00']).and_return(true)
      described_class.delete_old_sessions(2.hours, 1.day)
    end

    it 'Given strings' do
      Timecop.freeze(DateTime.new(2016, 10, 7, 23, 00))
      expect(Session).to receive(:destroy_all).with(['updated_at < ? OR created_at < ?', '2016-10-07 20:00:00', '2016-09-30 23:00:00']).and_return(true)
      described_class.delete_old_sessions('3 hours', '1 week')
    end

  end

end
