describe 'rake scheduled:clean:balanced_programme_cache' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    expect(ProgrammeReviewBalancedCache).to receive(:delete_old).and_return([:a, :b, :c, :d])
    expect(STDOUT).to receive(:puts).with('4 programme review caches deleted.')
    expect { task.execute }.not_to raise_error
  end

end
