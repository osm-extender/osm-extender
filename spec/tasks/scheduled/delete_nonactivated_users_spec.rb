describe 'rake scheduled:delete_nonactivated_users' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    expect(User).to receive_message_chain(:activation_expired, :destroy_all).and_return([User.new(id: 1), User.new(id: 5)])
    expect(STDOUT).to receive(:puts).with('2 users deleted')
    expect { task.execute }.not_to raise_error
  end

end
