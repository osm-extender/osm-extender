describe CreateStatisticsJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze(DateTime.new(2017, 6, 15, 15, 16, 17))
    expect(User).to receive(:minimum).with(:created_at).and_return(DateTime.new(2017, 6, 13, 10, 00, 00))
    expect(Statistics).to receive(:pluck).with(:date).and_return([Date.new(2017, 6, 13)])

    # Statistics already generated for this day
    expect(Statistics).to_not receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 13))
    # No statistics for this day
    expect(Statistics).to receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 14))
    # Current day - activity is stall happening
    expect(Statistics).to_not receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 15))

    expect { subject.perform }.not_to raise_error
  end

end
