describe "Status fetching" do

  describe '#unicorn_workers' do
    it 'Returns number of workers' do
      status = Status.new
      expect(IO).to receive(:read).with(File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')).and_return('1234')
      expect(status).to receive('`').with('pgrep -cP 1234').and_return('3')
      expect(status.unicorn_workers).to eq 3
    end

    it 'Handles missing PID file' do
      status = Status.new
      expect(IO).to receive(:read){ fail Errno::ENOENT, 'No such file or directory' }
      expect(status).to_not receive('`')
      expect(status.unicorn_workers).to eq 0
    end
  end # describe #unicorn_workers

  describe '#cache' do
    it 'Creates status' do
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
        cache_hits_percent: 88.95597974289053,
        cache_misses: 567,
        cache_misses_percent: 11.044020257109466,
        cache_attempts: 5134,
      })
    end

    it 'Handles zeros' do
      redis = double
      expect(Rails).to receive_message_chain(:cache, :data).and_return(redis)
      expect(redis).to receive(:config).with(:get, 'maxmemory').and_return('maxmemory'=>'0')
      expect(redis).to receive(:info).and_return('used_memory'=>'0', 'keyspace_hits'=>'0', 'keyspace_misses'=>'0')
      expect(redis).to receive(:dbsize).and_return(0)
      expect(Status.new.cache).to eq ({
        ram_max: 0,
        ram_used: 0,
        keys: 0,
        cache_hits: 0,
        cache_hits_percent: 0.0,
        cache_misses: 0,
        cache_misses_percent: 0.0,
        cache_attempts: 0,
      })
    end
  end # describe cache

  describe '#database_size' do
    it "Gets sizes of tables" do
      expect(Rails).to receive_message_chain(:configuration, :database_configuration).and_return({'test' => {'schema_search_path' => 'SCHEMA-NAME'}})
      expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT tablename FROM pg_tables WHERE schemaname IN ('SCHEMA-NAME') ORDER BY tablename;").and_return([
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

    it 'Handles no schema_search_path in config' do
      expect(Rails).to receive_message_chain(:configuration, :database_configuration).and_return({'test' => {}})
      expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT tablename FROM pg_tables WHERE schemaname IN ('public') ORDER BY tablename;").and_return([
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

    it 'Handles multiple schemas in schema_search_path in config' do
      expect(Rails).to receive_message_chain(:configuration, :database_configuration).and_return({'test' => {'schema_search_path' => 'SCHEMA-NAME-1,SCHEMA-NAME-2, SCHEMA-NAME-3'}})
      expect(ActiveRecord::Base.connection).to receive(:execute).with("SELECT tablename FROM pg_tables WHERE schemaname IN ('SCHEMA-NAME-1','SCHEMA-NAME-2','SCHEMA-NAME-3') ORDER BY tablename;").and_return([
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

  end # describe #database_size

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


  describe '#sessions' do
    it 'Gets counts & averages' do
      Timecop.freeze
      expect(Session).to receive_message_chain(:guests, :count).and_return(1)
      expect(Session).to receive_message_chain(:users, :count).and_return(2)
      expect(Session).to receive(:count).and_return(3)
      expect(Session).to receive(:first).and_return(Session.new(id: 1))
      expect(Session).to receive(:last).and_return(Session.new(id: 2))
      expect(Session).to receive(:pluck).with(:user_id, :created_at, :updated_at).and_return([
        [1, 10.minutes.ago, 8.minutes.ago],
        [2, 8.minutes.ago, 4.minutes.ago],
        [nil, 15.minutes.ago, 14.minutes.ago],
      ])

      # Actually get them
      expect(Status.new.sessions).to eq ({
        totals: {
          all: 3,
          users: 2,
          guests: 1,
        },
        average_durations: {
          all: 2.minutes + 20.seconds,
          users: 3.minutes,
          guests: 1.minutes,
        },
        average_ages: {
          all: 11.minutes,
          users: 9.minutes,
          guests: 15.minutes,
        },
        oldest: Session.new(id: 1),
        newest: Session.new(id: 2),
      })
    end

    it 'handles 0 sessions' do
      expect(Session).to receive_message_chain(:guests, :count).and_return(0)
      expect(Session).to receive_message_chain(:users, :count).and_return(0)
      expect(Session).to receive(:count).and_return(0)
      expect(Session).to receive(:first).and_return(nil)
      expect(Session).to receive(:last).and_return(nil)
      expect(Session).to receive(:pluck).with(:user_id, :created_at, :updated_at).and_return([])

      # Actually get them
      expect(Status.new.sessions).to eq ({
        totals: {all: 0, users: 0, guests: 0},
        average_durations: {all: 0, users: 0, guests: 0},
        average_ages: {all: 0, users: 0, guests: 0},
        oldest: nil,
        newest: nil,
      })
    end

  end # describe #sessions

end
