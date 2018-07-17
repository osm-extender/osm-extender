describe 'rake app:deploy:wait_for_migrations' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Waits for migrations to be applied' do
    expect(Kernel).to receive(:sleep)
    expect(ActiveRecord::Migrator).to receive(:needs_migration?).and_return(true, false)
    expect { task.execute }.not_to raise_error
  end

  it 'No migrations waiting' do
    expect(ActiveRecord::Migrator).to receive(:needs_migration?).and_return(false)
    expect { task.execute }.not_to raise_error
  end

  it 'Sleeps with increasing intervals before failing' do
    expect(ActiveRecord::Migrator).to receive(:needs_migration?).at_least(1).and_return(true)
    expect(Kernel).to receive(:sleep).ordered.with(30)
    expect(Kernel).to receive(:sleep).ordered.with(60)
    expect(Kernel).to receive(:sleep).ordered.with(120)
    expect(Kernel).to receive(:sleep).ordered.with(240)
    expect(Kernel).to receive(:sleep).ordered.with(480)
    expect { task.execute }.to raise_error ActiveRecord::PendingMigrationError
  end
end
