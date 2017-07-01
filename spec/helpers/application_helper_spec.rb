describe ApplicationHelper do

  describe '#asset_exists?' do
    context 'in a development type environment' do
      before do
        @application = double
        allow(Rails).to receive(:application).and_return(@application)
        expect(@application).to receive_message_chain(:config, :assets, :compile).and_return(true)
      end
      it 'the asset exists' do
        expect(@application).to receive_message_chain(:assets, :find_asset).with('test/path').and_return(true)
        expect(helper.asset_exists?('test/path')).to eq true
      end
      it 'the asset does not exist' do
        expect(@application).to receive_message_chain(:assets, :find_asset).with('test/path').and_return(nil)
        expect(helper.asset_exists?('test/path')).to eq false
      end
    end # contect in a development type environment

    context 'in a production type environment' do
      before do
        @application = double
        allow(Rails).to receive(:application).and_return(@application)
        expect(@application).to receive_message_chain(:config, :assets, :compile).and_return(false)
      end
      it 'the asset exists' do
        expect(@application).to receive_message_chain(:assets_manifest, :files, :values).and_return([{'logical_path' => 'test/path'}])
        expect(helper.asset_exists?('test/path')).to eq true
      end
      it 'the asset does not exist' do
        expect(@application).to receive_message_chain(:assets_manifest, :files, :values).and_return([{'logical_path' => 'another/path'}])
        expect(helper.asset_exists?('test/path')).to eq false
      end
    end # contect in a production type environment
  end # decribe #asset_exists?


  describe '#javascript_include_tag_if_exists' do
    it 'Exists' do
      expect(helper).to receive(:asset_exists?).with('path/to/javascript.js').and_return(true)
      expect(helper.javascript_include_tag_if_exists('path/to/javascript')).to eq '<script src="/javascripts/path/to/javascript.js"></script>'
    end
    it 'Does not exist' do
      expect(helper).to receive(:asset_exists?).with('path/to/javascript.js').and_return(false)
      expect(helper.javascript_include_tag_if_exists('path/to/javascript')).to be_nil
    end
    it 'Passes options to javascript_include_tag helper' do
      expect(helper).to receive(:asset_exists?).with('path/to/javascript.js').and_return(true)
      expect(helper).to receive(:javascript_include_tag).with('path/to/javascript', {option_a: 'a', option_b: 'b'}).and_return('')
      helper.javascript_include_tag_if_exists('path/to/javascript', option_a: 'a', option_b: 'b')
    end
  end # describe #javascript_include_tag_if_exists


  describe '#stylesheet_link_tag_if_exists' do
    it 'Exists' do
      expect(helper).to receive(:asset_exists?).with('path/to/stylesheet.css').and_return(true)
      expect(helper.stylesheet_link_tag_if_exists('path/to/stylesheet')).to eq '<link rel="stylesheet" media="screen" href="/stylesheets/path/to/stylesheet.css" />'
    end
    it 'Does not exist' do
      expect(helper).to receive(:asset_exists?).with('path/to/stylesheet.css').and_return(false)
      expect(helper.stylesheet_link_tag_if_exists('path/to/stylesheet')).to be_nil
    end
    it 'Passes options to stylesheet_link_tag helper' do
      expect(helper).to receive(:asset_exists?).with('path/to/stylesheet.css').and_return(true)
      expect(helper).to receive(:stylesheet_link_tag).with('path/to/stylesheet', {option_a: 'a', option_b: 'b'}).and_return('')
      helper.stylesheet_link_tag_if_exists('path/to/stylesheet', option_a: 'a', option_b: 'b')
    end
  end # describe #stylesheet_link_tag_if_exists


  describe '#do_by_time' do
    before do
      Timecop.freeze DateTime.new(2000, 1, 1, 9, 15, 0)
    end
    it 'is today' do
      expect(helper.do_by_time DateTime.new(2000, 1, 1, 10, 45, 0)).to eq '10:45 today'
    end
    it 'is tomorrow' do
      expect(helper.do_by_time DateTime.new(2000, 1, 2, 18, 30, 0)).to eq '18:30 tomorrow'
    end
    it 'is this week' do
      expect(helper.do_by_time DateTime.new(2000, 1, 3, 10, 0, 0)).to eq '10:00 on Monday'
    end
    it 'is further away' do
      expect(helper.do_by_time DateTime.new(2000, 1, 8, 10, 0, 0)).to eq '10:00 on Saturday 8th January'
    end
    it 'is next year' do
      expect(helper.do_by_time DateTime.new(2001, 1, 1, 10, 0, 0)).to eq '10:00 on 1st January 2001'
    end
    it 'in the past' do
      expect(helper.do_by_time DateTime.new(1999, 12, 31, 10, 0, 0)).to eq '10:00 on 31st December 1999'
    end
  end # describe #do_by_time


  describe '#ordinalized_date' do
    it 'With %e in format string' do
      expect(helper.ordinalized_date Date.new(2000, 1, 1), '%e %B %Y').to eq ' 1st January 2000'
    end
    it 'With %d in format string' do
      expect(helper.ordinalized_date Date.new(2000, 1, 1), '%d %B %Y').to eq '01st January 2000'
    end
    it 'With %-d in format string' do
      expect(helper.ordinalized_date Date.new(2000, 1, 1), '%-d %B %Y').to eq '1st January 2000'
    end
    it 'Without %e, %d or %-d in format string' do
      expect(helper.ordinalized_date Date.new(2000, 1, 1), '%j %B %Y').to eq '001 January 2000'
    end
  end # describe #ordinalized_date


  it '#page_title' do
    expect(helper).to receive(:provide).with(:title, 'Title')
    expect(helper).to receive(:content_tag).with('h1', 'Title')
    expect(helper.page_title 'Title').to be_nil
  end


  describe '#seconds_to_time' do

    it 'A second' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.second.to_i)).to eq '1 second'
    end

    it 'Under a minute' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(45.seconds.to_i)).to eq '45 seconds'
    end

    it 'A minute' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.minute.to_i)).to eq '1 minute'
    end

    it '1 minute and 30 seconds' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(90.seconds.to_i)).to eq '1 minute and 30 seconds'
    end

    it '2 minutes' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.minutes.to_i)).to eq '2 minutes'
    end

    it 'An hour' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.hour.to_i)).to eq '1 hour'
    end

    it '1 hour and 30 minutes' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(90.minutes.to_i)).to eq '1 hour and 30 minutes'
    end

    it '2 hours' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.hours.to_i)).to eq '2 hours'
    end

    it 'A day' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.day.to_i)).to eq '1 day'
    end

    it '1 day and 12 hours' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(36.hours.to_i)).to eq '1 day and 12 hours'
    end

    it '2 days' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.days.to_i)).to eq '2 days'
    end

    it 'A week' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(1.week.to_i)).to eq '1 week'
    end

    it '1 week and 2 days' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(9.days.to_i)).to eq '1 week and 2 days'
    end

    it '2 weeks' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time(2.weeks.to_i)).to eq '2 weeks'
    end

    it '1 week, 2 days, 3 hours and 1 second' do
      Timecop.travel(Time.local(2018, 11, 30))
      expect(helper.seconds_to_time((1.week + 2.days + 3.hours + 1.second).to_i)).to eq '1 week, 2 days, 3 hours and 1 second'
    end

  end # describe #seconds_to_time


  describe '#yes_no' do
    context 'where true is good' do
      it 'and value is true' do
        expect(helper.yes_no(true, true)).to eq '<span style="color: green;">yes</span>'
      end
      it 'and value is false' do
        expect(helper.yes_no(false, true)).to eq '<span style="color: red;">NO</span>'
      end
    end # context where true is good
    context 'where false is good' do
      it 'and value is true' do
        expect(helper.yes_no(true, false)).to eq '<span style="color: red;">YES</span>'
      end
      it 'and value is false' do
        expect(helper.yes_no(false, false)).to eq '<span style="color: green;">no</span>'
      end
    end # context where false is good
  end # describe #yes_no

  describe '#pos_neg' do
    context 'where true is good' do
      it 'and value is true' do
        expect(helper.pos_neg(true, true, 'text')).to eq '<span style="color: green;">text</span>'
      end
      it 'and value is false' do
        expect(helper.pos_neg(false, true, 'text')).to eq '<span style="color: red;">text</span>'
      end
    end # context where true is good
    context 'where false is good' do
      it 'and value is true' do
        expect(helper.pos_neg(true, false, 'text')).to eq '<span style="color: red;">text</span>'
      end
      it 'and value is false' do
        expect(helper.pos_neg(false, false, 'text')).to eq '<span style="color: green;">text</span>'
      end
    end # context where false is good
  end # describe #pos_neg


  describe '#html_from_log_lines' do
    it 'handles simple array' do
      lines = ['Line 1', 'Line 2', 'Line 3']
      expect(helper.html_from_log_lines lines).to eq '<ol><li>Line 1</li><li>Line 2</li><li>Line 3</li></ol>'
    end
    it 'handles line which is an array' do
      lines = ['Line 1', ['Line 2A', 'Line 2B'], 'Line 3']
      expect(helper.html_from_log_lines lines).to eq '<ol><li>Line 1</li><ol><li>Line 2A</li><li>Line 2B</li></ol><li>Line 3</li></ol>'
    end
    it 'handles multiple arrays deep' do
      lines = [
        'Line 1',
        ['Line 2'],
        [['Line 3']],
        [[['Line 4']]],
        [[[['Line 5']]]],
        [[[[['Line 6']]]]],
        [[[[[['Line 7']]]]]],
        [[[[[[['Line 8']]]]]]],
        [[[[[[[['Line 9']]]]]]]],
      ]
      expect(helper.html_from_log_lines lines).to eq '<ol><li>Line 1</li><ol><li>Line 2</li></ol><ol><ol><li>Line 3</li></ol></ol><ol><ol><ol><li>Line 4</li></ol></ol></ol><ol><ol><ol><ol><li>Line 5</li></ol></ol></ol></ol><ol><ol><ol><ol><ol><li>Line 6</li></ol></ol></ol></ol></ol><ol><ol><ol><ol><ol><ol><li>Line 7</li></ol></ol></ol></ol></ol></ol><ol><ol><ol><ol><ol><ol><ol><li>Line 8</li></ol></ol></ol></ol></ol></ol></ol><ol><ol><ol><ol><ol><ol><ol><ol><li>Line 9</li></ol></ol></ol></ol></ol></ol></ol></ol></ol>'
    end
    it 'skips empty lines' do
      lines = ['Line 1', '', 'Line 3']
      expect(helper.html_from_log_lines lines).to eq '<ol><li>Line 1</li><li>Line 3</li></ol>'
    end
  end # describe #html_from_log_lines


  describe '#text_from_log_lines' do
    it 'handles simple array' do
      lines = ['Line 1', 'Line 2', 'Line 3']
      expect(helper.text_from_log_lines lines).to eq "* Line 1\n* Line 2\n* Line 3"
    end
    it 'handles line which is an array' do
      lines = ['Line 1', ['Line 2A', 'Line 2B'], 'Line 3']
      expect(helper.text_from_log_lines lines).to eq "* Line 1\n    + Line 2A\n    + Line 2B* Line 3"
    end
    it 'handles multiple arrays deep' do
      lines = [
        'Line 1',
        ['Line 2'],
        [['Line 3']],
        [[['Line 4']]],
        [[[['Line 5']]]],
        [[[[['Line 6']]]]],
        [[[[[['Line 7']]]]]],
        [[[[[[['Line 8']]]]]]],
        [[[[[[[['Line 9']]]]]]]],
      ]
      expect(helper.text_from_log_lines lines).to eq "* Line 1\n    + Line 2        > Line 3            - Line 4                * Line 5                    + Line 6                        > Line 7                            - Line 8                                * Line 9"
    end
    it 'skips empty lines' do
      lines = ['Line 1', '', 'Line 3']
      expect(helper.text_from_log_lines lines).to eq "* Line 1\n* Line 3"
    end
  end

end

