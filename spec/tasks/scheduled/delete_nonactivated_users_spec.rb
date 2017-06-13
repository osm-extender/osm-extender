describe 'rake scheduled:delete_nonactivated_users', type: :task do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      expect(User).to receive_message_chain(:activation_expired, :destroy_all).and_return([User.new(id: 1), User.new(id: 5)])
    end

    it 'Destroys relevant users' do
      expect { task.execute }.not_to raise_error
    end

    it "Logs to stdout" do
      expect { task.execute }.to output("2 users deleted\n").to_stdout
    end

  end # describe Executes

end
