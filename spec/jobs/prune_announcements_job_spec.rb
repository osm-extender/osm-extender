describe PruneAnnouncementsJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    where = double(ActiveRecord::QueryMethods::WhereChain)
    expect(Announcement).to receive(:where).with(['updated_at <= :when AND finish <= :when', when: 6.months.ago]).and_return(where)
    expect(where).to receive(:destroy_all).and_return([:a, :b])
    expect { subject.perform }.not_to raise_error
  end

end
