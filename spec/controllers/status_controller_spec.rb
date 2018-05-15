describe StatusController do

  mime_types = {
    'cacti' => 'text/plain',
    'json' => 'application/json; charset=utf-8',
    'csv' => 'text/csv',
    'text_table' => 'text/plain',
    'html' => 'text/html',
    'text' => 'text/plain; charset=utf-8'
  }
  response_bodies = {
     cache: {
       'cacti' => "ram_max:2048 ram_used:1024 keys:723 cache_hits:100 cache_misses:25 cache_attempts:125\n",
       'json' => '{"ram_max":2048,"ram_used":1024,"keys":723,"cache_hits":100,"cache_misses":25,"cache_attempts":125}',
       'csv' => "Ram Max,Ram Used,Keys,Cache Hits,Cache Misses,Cache Attempts\n2048,1024,723,100,25,125\n",
       'text_table' => "+----------------+------+\n| Ram Max        | 2048 |\n| Ram Used       | 1024 |\n| Keys           | 723  |\n| Cache Hits     | 100  |\n| Cache Misses   | 25   |\n| Cache Attempts | 125  |\n+----------------+------+",
    },
     database_size: {
       'cacti' => "t1s_size:1024 t1s_count:128 t2s_size:2048 t2s_count:256 total_count:125 total_size:1024\n",
       'json' => '{"totals":{"count":125,"size":1024},"tables":[{"model":"T1","table":"t1s","count":128,"size":1024},{"model":"T2","table":"t2s","count":256,"size":2048}]}',
       'csv' => "Model,Table,Count,Size\nT1,t1s,1024,128\nT2,t2s,2048,256\n,TOTAL,1024,125\n",
       'text_table' => "+-------+-------+-------+------+\n| Model | Table | Count | Size |\n+-------+-------+-------+------+\n| T1    | t1s   | 1024  | 128  |\n| T2    | t2s   | 2048  | 256  |\n+-------+-------+-------+------+\n|       |       | 1024  | 125  |\n+-------+-------+-------+------+",
    },
     delayed_job: {
       'cacti' => "settings_default_priority:5 settings_max_attempts:5 settings_max_run_time:14400 settings_sleep_delay:15 settings_destroy_failed_jobs:false settings_delay_jobs:false jobs_total:10 jobs_locked:2 jobs_failed:3 jobs_cron:4\n",
       'json' => '{"settings":{"default_priority":5,"max_attempts":5,"max_run_time":14400,"sleep_delay":15,"destroy_failed_jobs":false,"delay_jobs":false},"jobs":{"total":10,"locked":2,"failed":3,"cron":4}}',
       'csv' => "Status,Count\ntotal,10\nlocked,2\nfailed,3\ncron,4\n",
       'text_table' => "+--------+-------+\n| Status | Count |\n+--------+-------+\n| Locked | 2     |\n| Failed | 3     |\n| Cron   | 4     |\n+--------+-------+\n| Total  | 10    |\n+--------+-------+",
    },
    health: {
      'cacti' => "healthy:1\n",
      'json' => '{"healthy":true,"ok":[],"not_ok":[]}',
      'csv' => "\n",
      'text_table' => "++\n++",
      'text' => "HEALTHY\n",
     },
     unicorn_workers: {
       'cacti' => "6\n",
       'json' => '6',
       'csv' => "6\n",
       'text_table' => "+---+\n| 6 |\n+---+",
    },
     users: {
       'cacti' => 'unactivated:1 activated:2 connected:3 total:6' + "\n",
       'json' => '{"unactivated":1,"activated":2,"connected":3,"total":6}',
       'csv' => "Unactivated,Activated,Connected,Total\n1,2,3,6\n",
       'text_table' => "+-------------+---+\n| Unactivated | 1 |\n| Activated   | 2 |\n| Connected   | 3 |\n+-------------+---+\n| Total       | 6 |\n+-------------+---+",
    },
  }

  let(:status) { Status.new }
  let(:user_without_permission) { create :user, can_view_status: false }
  let(:user_with_permission) { create :user, can_view_status: true }



  describe 'User with permission' do
    before(:each) { signin user_with_permission }
    before(:each) do
      expect(Status).to receive(:new).and_return(status)
      allow(status).to receive(:health).and_return({healthy: true, ok: [], not_ok: []})
      allow(status).to receive(:unicorn_workers).and_return(6)
      allow(status).to receive(:cache).and_return({ram_max: 2048, ram_used: 1024, keys: 723, cache_hits: 100, cache_hits_percent: 80, cache_misses: 25, cache_misses_percent: 20, cache_attempts: 125})
      allow(status).to receive(:users).and_return({unactivated: 1, activated: 2, connected: 3, total: 6})
      allow(status).to receive(:database_size).and_return({
        totals: {count: 125, size: 1024},
        tables: [
          {model: 'T1', table:'t1s', count: 128, size: 1024},
          {model: 'T2', table:'t2s', count: 256, size: 2048},
        ]
      })
      allow(status).to receive(:delayed_job).and_return({
        settings: {
          default_priority: 5,
          max_attempts: 5,
          max_run_time: 14400,
          sleep_delay: 15,
          destroy_failed_jobs: false,
          delay_jobs: false
        },
        jobs: {
          total: 10,
          locked: 2,
          failed: 3,
          cron: 4,
        }
      })
    end

    describe '#index' do
      before(:each) { get :index, key: 'a' }
      it { expect(response).to be_success }
      it { expect(response.headers["Content-Type"]).to eq "text/html; charset=utf-8" }
      it { expect(response).to render_template :index }    
    end

    response_bodies.each do |method, bodies|
      bodies.each do |format, body|
        describe "#{method.to_s.titleize} as #{format}" do
          before(:each) { get method, format: format, key: 'a' }
          it { expect(response).to be_success }
          it { expect(response.headers["Content-Type"]).to eq mime_types[format] }
          it { expect(response.body).to eq body }    
        end # describe
      end # format
    end # method

    describe 'Health (unhealthy)' do
      unhealthy_bodies = {
        'cacti' => "healthy:0\n",
        'json' => '{"healthy":false,"ok":[],"not_ok":[]}',
        'csv' => "\n",
        'text_table' => "++\n++",
        'text' => "UNHEALTHY\n",
      }
      before(:each) { allow(status).to receive(:health).and_return({healthy: false, ok: [], not_ok: []}) }
      unhealthy_bodies.each do |format, body|
        describe "as #{format}" do
          before(:each) { get :health, format: format, key: 'a' }
          it { expect(response.status).to eq 503 }
          it { expect(response.headers["Content-Type"]).to eq mime_types[format] }
          it { expect(response.body).to eq body }
        end # describe
      end # each format, body
    end # describe #health (unhealthy)

  end # describe user with permission


  describe 'Using key parameter' do
    context 'Valid' do
      before(:each) do
        expect(Status).to receive(:new).and_return(status)
        allow(status).to receive(:unicorn_workers).and_return(6)
        allow(status).to receive(:cache).and_return({ram_max: 2048, ram_used: 1024, keys: 723, cache_hits: 100, cache_hits_percent: 80, cache_misses: 25, cache_misses_percent: 20, cache_attempts: 125})
        allow(status).to receive(:users).and_return({unactivated: 1, activated: 2, connected: 3, total: 6})
        allow(status).to receive(:database_size).and_return({
          totals: {count: 125, size: 1024},
          tables: [
            {model: 'T1', table:'t1s', count: 128, size: 1024},
            {model: 'T2', table:'t2s', count: 256, size: 2048},
          ]
        })
        allow(status).to receive(:delayed_job).and_return({
          settings: {
            default_priority: 5,
            max_attempts: 5,
            max_run_time: 14400,
            sleep_delay: 15,
            destroy_failed_jobs: false,
            delay_jobs: false
          },
          jobs: {
            total: 10,
            locked: 2,
            failed: 3,
            cron: 4,
          }
        })
      end

      describe '#index' do
        before(:each) { get :index, key: 'test-a' }
        it { expect(response).to be_success }
        it { expect(response.headers["Content-Type"]).to eq "text/html; charset=utf-8" }
        it { expect(response).to render_template :index }    
      end

      response_bodies.each do |method, bodies|
        bodies.each do |format, body|
          describe "#{method.to_s.titleize} as #{format}" do
            before(:each) { get method, format: format, key: 'test-a' }
            it { expect(response).to be_success }
            it { expect(response.headers["Content-Type"]).to eq mime_types[format] }
            it { expect(response.body).to eq body }    
          end # describe
        end # format
      end # method
    end # context valid


    context 'Invalid' do
      before(:each) { expect(Status).to_not receive(:new) }

      describe '#index' do
        before(:each) { get :index, params: {key: 'key-invalid'} }
          it { expect(response).to redirect_to signin_path }
          it { expect(flash[:error]).to eq 'You are not allowed to do that.' }
      end

      response_bodies.each do |method, bodies|
        bodies.each do |format, body|
          describe "#{method.to_s.titleize} as #{format}" do
            before(:each) { get method, format: format, key: 'key-invalid' }
            it { expect(response).to redirect_to signin_path }
            it { expect(flash[:error]).to eq 'You are not allowed to do that.' }
          end # describe
        end # format
      end # method
    end # context invalid

  end # describe using key parameter



  describe 'User without permisison' do
    before(:each) { signin user_without_permission }
    before(:each) { expect(Status).to_not receive(:new) }

    describe '#index' do
      before(:each) { get :index }
      it { expect(response).to redirect_to my_page_path }
      it { expect(flash[:error]).to eq 'You are not allowed to do that.' }
    end

    response_bodies.each do |method, bodies|
      bodies.each do |format, body|
        describe "#{method.to_s.titleize} as #{format}" do
          before(:each) { get method, format: format }
          it { expect(response).to redirect_to my_page_path }
          it { expect(flash[:error]).to eq 'You are not allowed to do that.' }
        end # describe
      end # format
    end # method
  end # describe user without permission



  context 'Guest' do
    before(:each) { expect(Status).to_not receive(:new) }

    describe '#index' do
      before(:each) { get :index }
      it { expect(response).to redirect_to signin_path }
      it { expect(flash[:error]).to eq 'You are not allowed to do that.' }      
    end

    response_bodies.each do |method, bodies|
      bodies.each do |format, body|
        describe "##{method.to_s.titleize} as #{format}" do
          before(:each) { get method, {format: format} }
          it { expect(response).to redirect_to signin_path }
          it { expect(flash[:error]).to eq 'You are not allowed to do that.' }
        end # describe
      end # format
    end # method
  end # context guest

end
