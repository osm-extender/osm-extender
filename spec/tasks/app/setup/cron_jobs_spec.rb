describe 'rake app:setup:cron_jobs' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Add jobs' do
    before :each do
      Timecop.freeze DateTime.new 2000, 2, 14, 12, 15
      Delayed::Job.delete_all
      # Daily jobs get added
      expect(Delayed::Job).to receive(:create).with(handler: /AutomationTasksJob/, cron: '0 3 * * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /CreateStatisticsJob/, cron: '0 3 * * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /EmailListsJob/, cron: '0 3 * * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /PruneUnactivatedUsersJob/, cron: '0 3 * * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /ReminderEmailsJob/, cron: '0 3 * * *', run_at: 1.minute.from_now).and_return(true)
      # Monthly jobs get added
      expect(Delayed::Job).to receive(:create).with(handler: /PruneAnnouncementsJob/, cron: '0 1 1 * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /PruneBalancedProgrammeCacheJob/, cron: '0 1 1 * *', run_at: 1.minute.from_now).and_return(true)
      expect(Delayed::Job).to receive(:create).with(handler: /PrunePaperTrailsJob/, cron: '0 1 1 * *', run_at: 1.minute.from_now).and_return(true)
    end

    it 'Outputs progress' do
      lines = [
        "Adding cron jobs",
        "\t0 3 * * *\t2000-02-15 03:00:00 +0000",
        "\t\tAutomationTasksJob - not found - adding",
        "\t\tCreateStatisticsJob - not found - adding",
        "\t\tEmailListsJob - not found - adding",
        "\t\tPruneUnactivatedUsersJob - not found - adding",
        "\t\tReminderEmailsJob - not found - adding",
        "\t0 1 1 * *\t2000-03-01 01:00:00 +0000",
        "\t\tPruneAnnouncementsJob - not found - adding",
        "\t\tPruneBalancedProgrammeCacheJob - not found - adding",
        "\t\tPrunePaperTrailsJob - not found - adding",
      ]
      expect { task.execute }.to output(lines.join("\n") + "\n").to_stdout
    end

    it "Doesn't raise an error" do
      expect { task.execute }.not_to raise_error
    end
  end # describe Add jobs


  describe "Doesn't add a second job" do
    before :each do
      Timecop.freeze DateTime.new 2000, 2, 14, 12, 15
      Delayed::Job.create!([
        {handler: "--- !ruby/object:AutomationTasksJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:CreateStatisticsJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:EmailListsJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:PruneUnactivatedUsersJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:ReminderEmailsJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:PruneAnnouncementsJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:PruneBalancedProgrammeCacheJob\narguments: []\n", cron: '* * * * *'},
        {handler: "--- !ruby/object:PrunePaperTrailsJob\narguments: []\n", cron: '* * * * *'},
      ])

      expect(Delayed::Job).not_to receive(:create)
    end

    it 'Outputs progress' do
      lines = [
        "Adding cron jobs",
        "\t0 3 * * *\t2000-02-15 03:00:00 +0000",
        "\t\tAutomationTasksJob - already exists - not adding another",
        "\t\tCreateStatisticsJob - already exists - not adding another",
        "\t\tEmailListsJob - already exists - not adding another",
        "\t\tPruneUnactivatedUsersJob - already exists - not adding another",
        "\t\tReminderEmailsJob - already exists - not adding another",
        "\t0 1 1 * *\t2000-03-01 01:00:00 +0000",
        "\t\tPruneAnnouncementsJob - already exists - not adding another",
        "\t\tPruneBalancedProgrammeCacheJob - already exists - not adding another",
        "\t\tPrunePaperTrailsJob - already exists - not adding another",
      ]
      expect { task.execute }.to output(lines.join("\n") + "\n").to_stdout
    end

    it "Doesn't raise an error" do
      expect { task.execute }.not_to raise_error
    end
  end # describe Doesn't add a second job

end
