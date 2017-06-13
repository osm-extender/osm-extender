describe "Status fetching" do

  it "#unicorn_workers" do
    status = Status.new
    expect(IO).to receive(:read).with(File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')).and_return('1234')
    expect(status).to receive('`').with('pgrep -cP 1234').and_return('3')
    expect(status.unicorn_workers).to eq 3
  end

  describe "Cache status" do
    before :each do
      @cache = Struct.new(:cache, :data).new
    end

    it "cache_used" do
      status = Status.new
      expect(status).to receive(:cache_info).and_return({'used_memory'=>'1234'})
      expect(status.cache_used).to eq(1234)
    end

    it "cache_maximum" do
      status = Status.new
      expect(Rails.cache).to receive(:data).and_return(@cache)
      expect(@cache).to receive(:config).with(:get, 'maxmemory').and_return({'maxmemory'=>'2345'})
      expect(status.cache_maximum).to eq(2345)
    end

    it "cache_keys" do
      status = Status.new
      expect(Rails.cache).to receive(:data).and_return(@cache)
      expect(@cache).to receive(:dbsize).and_return(3456)
      expect(status.cache_keys).to eq(3456)
    end

    it "cache_hits" do
      status = Status.new
      expect(status).to receive(:cache_info).and_return({'keyspace_hits'=>'4567'})
      expect(status.cache_hits).to eq(4567)
    end

    it "cache_misses" do
      status = Status.new
      expect(status).to receive(:cache_info).and_return({'keyspace_misses'=>'567'})
      expect(status.cache_misses).to eq(567)
    end

    it "Doesn't make multiple calls to redis.info" do
      status = Status.new
      expect(Rails.cache).to receive(:data).and_return(@cache)
      expect(@cache).to receive(:info).once.and_return({
        'used_memory'=>'123',
        'keyspace_hits'=>'456',
        'keyspace_misses'=>'789',
      })
      expect(status.cache_used).to eq(123)
      expect(status.cache_hits).to eq(456)
      expect(status.cache_misses).to eq(789)      
    end

  end # describe cache status


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
