describe DbSessionStore do

  describe '#get_session' do

    describe 'Session exists' do

      it 'With user' do
        session = Session.new(id: 1, session_id: 'session_id', user_id: 3, data: {4 => 'four'})
        expect(Session).to receive(:find_by_session_id).with('session_id').and_return(session)
        store = described_class.new(nil)
        expect(store.get_session(nil, 'session_id')).to eq ['session_id', {4 => 'four', 'user_id' => 3}]
      end

      it 'Without user' do
        session = Session.new(id: 1, session_id: 'session_id', user_id: nil, data: {4 => 'four'})
        expect(Session).to receive(:find_by_session_id).with('session_id').and_return(session)
        store = described_class.new(nil)
        expect(store.get_session(nil, 'session_id')).to eq ['session_id', {4 => 'four'}]
      end

    end # # describe session exists

    it "Session doesn't exist" do
      expect(Session).to receive(:find_by_session_id).with('session_id').and_return(nil)
      session = Session.new(id: 1, session_id: 'session_id')
      expect(Session).to receive(:create).with(session_id: 'session_id').and_return(session)
      store = described_class.new(nil)
      expect(store.get_session(nil, 'session_id')).to eq ['session_id', {}]
    end

    it 'Session ID is nil' do # create new session
      expect_any_instance_of(described_class).to receive(:generate_sid).and_return('NEW SESSION ID')
      session = Session.new(id: 1, session_id: 'NEW SESSION ID')
      expect(Session).to receive(:create).with(session_id: 'NEW SESSION ID').and_return(session)
      store = described_class.new(nil)
      expect(store.get_session(nil, nil)).to eq ['NEW SESSION ID', {}]
    end

  end


  describe '#set_session' do

    describe 'Session exists' do

     before :each do
        @session = Session.new(id: 1, session_id: 'session_id')
        expect(Session).to receive(:find_by_session_id).with('session_id').and_return(@session)
        expect(@session).to receive('data=').with('array' => [])
        expect(@session).to receive(:save!).and_return(true)
     end

      it 'With user' do
        expect(@session).to receive('user_id=').with(2)
        store = described_class.new(nil)
        expect(store.set_session(nil, 'session_id', {'user_id' => 2, 'array' => []}, {})).to eq 'session_id'
      end

      it 'Without user' do
        expect(@session).to receive('user_id=').with(nil)
        store = described_class.new(nil)
        expect(store.set_session(nil, 'session_id', {'array' => []}, {})).to eq 'session_id'
      end

    end # describe Session exists

    it "Session doesn't exist" do
      session = Session.new(id: 1, session_id: 'session_id')
      expect(Session).to receive(:find_by_session_id).with('session_id').and_return(nil)
      expect(Session).to receive(:new).and_return(session)
      expect(session).to receive('user_id=').with(2)
      expect(session).to receive('data=').with('array' => [])
      expect(session).to receive(:save!).and_return(true)
      store = described_class.new(nil)
      expect(store.set_session(nil, 'session_id', {'user_id' => 2, 'array' => []}, {})).to eq 'session_id'
    end

  end


  describe '#destroy_session' do

    it 'Session exists' do
      expect_any_instance_of(described_class).to receive(:generate_sid).and_return('NEW SESSION ID')
      expect(Session).to receive(:destroy_all).with(session_id: 'session_id')
      store = described_class.new(nil)
      expect(store.destroy_session(nil, 'session_id', {})).to eq 'NEW SESSION ID'
    end

    it "Session doesn't exist" do
      expect_any_instance_of(described_class).to receive(:generate_sid).and_return('NEW SESSION ID')
      expect(Session).to receive(:destroy_all).with(session_id: 'session_id')
      store = described_class.new(nil)
      expect(store.destroy_session(nil, 'session_id', {})).to eq 'NEW SESSION ID'
    end

    it 'Drop option given' do
      expect(Session).to receive(:destroy_all).with(session_id: 'session_id')
      store = described_class.new(nil)
      expect(store.destroy_session(nil, 'session_id', {drop: true})).to be_nil
    end

  end

end
