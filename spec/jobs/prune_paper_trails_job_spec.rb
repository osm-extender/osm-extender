describe PrunePaperTrailsJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    expect(PaperTrail::Version).to receive(:destroy_all).with(['created_at <= ?', 3.months.ago]).and_return([:a, :b, :c, :d, :e, :f])
    expect { subject.perform }.not_to raise_error
  end

end
