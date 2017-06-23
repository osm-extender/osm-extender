describe 'rake scheduled:clean:announcements' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    expect(Announcement).to receive(:delete_old).and_return([:a])
    expect(STDOUT).to receive(:puts).with('1 announcements deleted.')
    expect { task.execute }.not_to raise_error
  end

end
