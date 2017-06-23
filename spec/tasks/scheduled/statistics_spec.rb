describe 'rake scheduled:statistics' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    it 'Generates statistics for relevant dates' do
      Timecop.freeze(DateTime.new(2017, 6, 15, 15, 16, 17))
      expect(User).to receive(:minimum).with(:created_at).and_return(DateTime.new(2017, 6, 13, 10, 00, 00))
      expect(Statistics).to receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 13))
      expect(Statistics).to receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 14))
      expect(Statistics).to_not receive(:create_or_retrieve_for_date).with(Date.new(2017, 6, 15))      
      expect { task.execute }.not_to raise_error
    end

  end # describe Executes

end
