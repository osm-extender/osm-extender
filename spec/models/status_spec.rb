require 'spec_helper'

describe "Status fetching" do

  it "Gets number of unicorn workers" do
    status = Status.new
    expect(IO).to receive(:read).with(File.join(Rails.root, 'tmp', 'pids', 'server.pid')).and_return('1234')
    expect(status).to receive('`').with('pgrep -cP 1234').and_return('3')
    expect(status.unicorn_workers).to eq 3
  end

  it "Gets total sessions" do
    status = Status.new
    expect(Session).to receive(:count).and_return(4)
    expect(status.total_sessions).to eq 4
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

end
