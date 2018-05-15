describe PruneBalancedProgrammeCacheJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    expect(ProgrammeReviewBalancedCache).to receive(:destroy_all).with(['last_used_at <= ?', 1.year.ago]).and_return([:a, :b, :c, :d])
    expect { subject.perform }.not_to raise_error
  end

end
