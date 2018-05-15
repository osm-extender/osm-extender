describe PruneAnnouncementsJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    expect(Announcement).to receive(:destroy_all).with(['updated_at <= :when AND finish <= :when', when: 6.months.ago]).and_return([:a, :b])
    expect { subject.perform }.not_to raise_error
  end

end
