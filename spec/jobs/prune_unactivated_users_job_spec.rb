describe PruneUnactivatedUsersJob do
  let(:subject) { described_class.new }

  it 'Performs' do
    Timecop.freeze
    unactivated_users = double User.activation_expired
    expect(User).to receive(:activation_expired).and_return(unactivated_users)
    expect(unactivated_users).to receive(:destroy_all).and_return([])
    expect { subject.perform }.not_to raise_error
  end

end
