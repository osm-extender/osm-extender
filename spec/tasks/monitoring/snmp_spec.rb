describe 'rake monitoring:snmp' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'Executes' do
    expect(STDIN).to receive(:gets).and_return("DUMP\n")
    status = double(Status)
    allow(Status).to receive(:new).and_return(status)
    expect(status).to receive(:unicorn_workers).and_return(6)
    expect(status).to receive(:cache).and_return({ram_max: 2048, ram_used: 1024, keys: 723, cache_hits: 100, cache_hits_percent: 80, cache_misses: 25, cache_misses_percent: 20, cache_attempts: 125})
    expect(status).to receive(:users).and_return({unactivated: 1, activated: 2, connected: 3, total: 6})
    expect(status).to receive(:database_size).and_return({
      totals: {count: 125, size: 1024},
      tables: [
        {model: 'T1', table:'t1s', count: 128, size: 1024},
        {model: 'T2', table:'t2s', count: 256, size: 2048},
      ]
    })

    # Unicorn workers
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.1.1 = gauge: 6') # Unicorn workers
    # Cache
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.1 = gauge: 2048')   # Max RAM
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.2 = gauge: 1024')   # Used RAM
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.3 = gauge: 723')    # Keys
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.4 = gauge: 100')    # Hits
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.4.0 = gauge: 100')  # Hits
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.4.1 = gauge: 8000') # Hits (percent * 100)
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.5 = gauge: 25')     # Misses
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.5.0 = gauge: 25')   # Misses
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.5.1 = gauge: 2000') # Misses (percent * 100)
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.2.6 = gauge: 125')    # Attempts
    # Users
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.3.0 = gauge: 6')      # Total users
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.3.1 = gauge: 1')      # Unactivated users
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.3.2 = gauge: 2')      # Activated users
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.3.3 = gauge: 3')      # Connected users
    # Database size
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.5.1.0 = gauge: 125')  # Record count
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.5.2.0 = gauge: 1024') # Size
    # Database tables
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.1.1 = string: T1')  # First model name
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.1.2 = string: T2')  # Next model name
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.2.1 = string: t1s') # First table name
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.2.2 = string: t2s') # Next table name
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.3.1 = gauge: 128')  # First table records
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.3.2 = gauge: 256' ) # Next table records
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.4.1 = gauge: 1024') # First table size
    expect(STDOUT).to receive(:puts).with('.1.2.3.4.5.6.7.8.9.6.4.2 = gauge: 2048') # Next table size

    expect { task.execute(base_oid: '.1.2.3.4.5.6.7.8.9') }.to_not raise_error
  end

end
