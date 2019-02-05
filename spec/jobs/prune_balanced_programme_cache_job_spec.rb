describe PruneBalancedProgrammeCacheJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    where = double(ActiveRecord::QueryMethods::WhereChain)
    expect(ProgrammeReviewBalancedCache).to receive(:where).with(['last_used_at <= ?', 1.year.ago]).and_return(where)
    expect(where).to receive(:destroy_all).and_return([:a, :b, :c, :d])
    expect { subject.perform }.not_to raise_error
  end

end
