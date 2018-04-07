require 'tty-prompt'

describe 'rake app:setup' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Creates first user' do
    prompt = double(TTY::Prompt.new)
    expect(TTY::Prompt).to receive(:new).and_return(prompt)
    user = User.new
    expect(User).to receive(:new).and_return(user)
    expect(User).to receive(:none?).and_return(true)
    expect(prompt).to receive(:yes?).and_return(true)
    expect(prompt).to receive(:ask).with("What is the user's name?").and_return('Name')
    expect(prompt).to receive(:ask).with("What is the user's email address?").and_return('user@example.com')
    expect(user).to receive(:skip_activation_needed_email=).with(true)
    expect(user).to receive(:skip_activation_success_email=).with(true)
    expect(user).to receive(:activate!)
    expect(user).to receive(:save!)
    expect(STDOUT).to_not receive(:puts).with('ERRORS:')
    expect(STDOUT).to receive(:puts).with(/The user's password is /)
    expect { task.execute }.not_to raise_error
  end

  it "Doesn't create a second user" do
    expect(User).to receive(:none?).and_return(false)
    expect(User).to_not receive(:new)
    expect { task.execute }.not_to raise_error
  end

end

