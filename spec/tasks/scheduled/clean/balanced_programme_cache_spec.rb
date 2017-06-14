describe 'rake scheduled:clean:balanced_programme_cache' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      expect(ProgrammeReviewBalancedCache).to receive(:delete_old).and_return([:a, :b, :c, :d])
    end

    it 'Destroys relevant users' do
      expect { task.execute }.not_to raise_error
    end

    it 'Logs to stdout' do
      expect { task.execute }.to output("4 programme review caches deleted.\n").to_stdout
    end

  end # describe Executes

end
