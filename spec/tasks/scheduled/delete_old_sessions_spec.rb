describe 'rake scheduled:delete_old_sessions' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    expect(Session).to receive(:delete_old_sessions).and_return([Session.new(id: 1), Session.new(id: 5), Session.new(id: 23)])
    expect(STDOUT).to receive(:puts).with('3 sessions deleted.')
    expect { task.execute }.not_to raise_error
  end

end
