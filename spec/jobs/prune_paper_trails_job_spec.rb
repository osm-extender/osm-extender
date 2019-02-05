describe PrunePaperTrailsJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    where = double(ActiveRecord::QueryMethods::WhereChain)
    expect(PaperTrail::Version).to receive(:where).with(['created_at <= ?', 3.months.ago]).and_return(where)
    expect(where).to receive(:destroy_all).and_return([:a, :b, :c, :d, :e, :f])
    expect { subject.perform }.not_to raise_error
  end

end
