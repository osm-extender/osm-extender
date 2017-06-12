describe Base64MarshalSerializer do

  describe '#load' do

    it 'Given an empty string' do
      expect(described_class.load('')).to be_nil
    end

    it 'Given dumped data' do
      data = {a: 'a', b: 'b', c: ['c', 'C']}
      dumped_data = described_class.dump(data)
      expect(described_class.load(dumped_data)).to eq data
    end

  end

end
