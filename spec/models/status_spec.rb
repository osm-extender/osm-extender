describe "Status fetching" do

  it '#all' do
    status = Status.new
    expect(status).to receive(:unicorn_workers).and_return('DATA FOR UNICORN WORKERS')
    expect(status).to receive(:cache).and_return('DATA FOR CACHE')
    expect(status).to receive(:database_size).and_return('DATA FOR DATABASE SIZE')
    expect(status).to receive(:users).and_return('DATA FOR USERS')
    expect(status).to receive(:sessions).and_return('DATA FOR SESSIONS')
    expect(status.all).to eq ({
      unicorn_workers: 'DATA FOR UNICORN WORKERS',
      cache: 'DATA FOR CACHE',
      database_size: 'DATA FOR DATABASE SIZE',
      users: 'DATA FOR USERS',
      sessions: 'DATA FOR SESSIONS',
    })
  end

  it "#unicorn_workers" do
    status = Status.new
    expect(IO).to receive(:read).with(File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')).and_return('1234')
    expect(status).to receive('`').with('pgrep -cP 1234').and_return('3')
    expect(status.unicorn_workers).to eq 3
  end

  it '#cache' do
    redis = double
    expect(Rails).to receive_message_chain(:cache, :data).and_return(redis)
    expect(redis).to receive(:config).with(:get, 'maxmemory').and_return('maxmemory'=>'2345')
    expect(redis).to receive(:info).and_return('used_memory'=>'1234', 'keyspace_hits'=>'4567', 'keyspace_misses'=>'567')
    expect(redis).to receive(:dbsize).and_return(3456)
    expect(Status.new.cache).to eq ({
      ram_max: 2345,
      ram_used: 1234,
      keys: 3456,
      cache_hits: 4567,
      cache_misses: 567,
      cache_attempts: 5134,
    })
  end

  it '#database_size' do
    expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;").and_return([
      {'tablename' => 'table1s'},
      {'tablename' => 'table2s'}
    ])
    expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT pg_total_relation_size('table1s') AS size, COUNT(table1s) AS count FROM table1s;").and_return([{'count' => '100', 'size' => '1024'}])
    expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT pg_total_relation_size('table2s') AS size, COUNT(table2s) AS count FROM table2s;").and_return([{'count' => '200', 'size' => '2000'}])
    expect(Status.new.database_size).to eq ({
      tables: [
        {model: 'Table1', table: 'table1s', size: 1024, count: 100},
        {model: 'Table2', table: 'table2s', size: 2000, count: 200}
      ],
      totals: {
        count: 300,
        size: 3024
      }
    })
  end

  it '#users' do
    activated = double(ActiveRecord::Relation)
    expect(User).to receive_message_chain(:unactivated, :count).and_return(1)
    expect(User).to receive(:activated).and_return(activated).twice
    expect(activated).to receive_message_chain(:not_connected_to_osm, :count).and_return(2)
    expect(activated).to receive_message_chain(:connected_to_osm, :count).and_return(3)
    expect(User).to receive(:count).and_return(6)

    # Actually get them
    expect(Status.new.users).to eq ({
      unactivated: 1,
      activated: 2,
      connected: 3,
      total: 6
    })
  end

  it '#sessions' do
    expect(Session).to receive_message_chain(:guests, :count).and_return(5)
    expect(Session).to receive_message_chain(:users, :count).and_return(10)
    expect(Session).to receive(:count).and_return(15)
    expect(Session).to receive(:first).and_return(Session.new(id: 1))
    expect(Session).to receive(:last).and_return(Session.new(id: 2))

    # Actually get them
    expect(Status.new.sessions).to eq ({
      guests: 5,
      users: 10,
      total: 15,
      oldest: Session.new(id: 1),
      newest: Session.new(id: 2),
    })
  end

end
