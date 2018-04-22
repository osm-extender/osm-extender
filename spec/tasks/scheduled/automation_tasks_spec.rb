describe 'rake scheduled:automation_tasks' do

  it 'Preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'Executes' do

    before :each do
      @task = AutomationTask.new(
        id: 1234,
        section_id: 3,
        section_name: 'section_name',
        user: User.new(id: 2, name: 'user_name', email_address: 'name@example.com')
      )
      allow(@task).to receive('has_permissions?').and_return(true)
      allow(AutomationTask).to receive(:human_name).and_return('automation_task_name')
    end

    describe 'Runs task' do

      before :each do
        tasks = [@task]
        tasks_where = double
        expect(AutomationTask).to receive(:where).with(active: true).and_return(tasks_where)
        expect(tasks_where).to receive(:order).with(:section_id).and_return(tasks)
        expect(STDOUT).to receive(:puts).with('Performing automation tasks')
      end

      it 'Success' do
        expect(@task).to receive(:do_task).and_return(success: true)
        expect(STDOUT).to receive(:puts).with("\tDoing 1 of 1 (id: 1234)")
        expect { task.execute }.not_to raise_error
      end

      it 'Errors' do
        expect(@task).to receive(:do_task).and_return(errors: ['A error', 'B error'])
        expect(STDOUT).to receive(:puts).with("\tDoing 1 of 1 (id: 1234)")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['automation-task-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Performing Automation Tasks FAILED - Error'
        expect(mail.text_part.body.decoded).to include "Unfortunatly your automation_task_name automation task for section_name failed.\n\n* A error\n* B error"
      end

    end # describe runs task

    it 'No tasks to run' do
      tasks = []
      tasks_where = double
      expect(AutomationTask).to receive(:where).with(active: true).and_return(tasks_where)
      expect(tasks_where).to receive(:order).with(:section_id).and_return(tasks)
        expect(STDOUT).to receive(:puts).with('Performing automation tasks')
      expect(STDOUT).to receive(:puts).with("\tNo tasks to perform")
      expect { task.execute }.not_to raise_error
    end

    describe 'Handles exceptions' do

      before :each do
        @task = AutomationTask.new(
          id: 1234,
          section_id: 3,
          section_name: 'section_name',
          user: User.new(id: 2, name: 'user_name', email_address: 'name@example.com')
        )
        allow(@task).to receive('has_permissions?').and_return(true)
        allow(AutomationTask).to receive(:human_name).and_return('automation_task_name')
        tasks = [@task]
        tasks_where = double
        expect(AutomationTask).to receive(:where).with(active: true).and_return(tasks_where)
        expect(tasks_where).to receive(:order).with(:section_id).and_return(tasks)
        expect(STDOUT).to receive(:puts).with('Performing automation tasks')
        expect(STDOUT).to receive(:puts).with("\tDoing 1 of 1 (id: 1234)")
      end

      it 'Osm::Forbidden' do
        expect(@task).to receive(:do_task) { raise Osm::Forbidden }
        expect(STDOUT).to receive(:puts).with("\t\tUser is fobidden from fetching data")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['automation-task-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Performing Automation Tasks FAILED - Forbidden'
        expect(mail.text_part.body.decoded).to match "Whilst trying to process the automated tasks for section_name an\nerror occured - you can't access data in the section."
      end

      it 'Osm::Error::NoCurrentTerm' do
        expect(@task).to receive(:do_task) { raise Osm::Error::NoCurrentTerm }
        expect(STDOUT).to receive(:puts).with("\t\tNo current term for section")
        expect{ task.execute }.to change { ActionMailer::Base.deliveries.size }.by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq ['name@example.com']
        expect(mail.from).to eq ['automation-task-mailer@example.com']
        expect(mail.subject).to eq 'OSMExtender (TEST) - Performing Automation Tasks FAILED - No current term'
        expect(mail.text_part.body.decoded).to include "Whilst trying to run your automation_task_name task for\nsection_name an error occured - you can't access data in the\nsection."
      end

      it 'Exception' do
        exception = ArgumentError.new 'Just a test'
        expect(@task).to receive(:do_task) { raise exception }
        expect(STDOUT).to receive(:puts).with("\t\tAn Exception was raised (Just a test)")
        expect(Rollbar).to receive(:error).with(exception)
        expect { task.execute }.not_to raise_error
      end

    end # describe Handles exceptions

  end # describe Executes

end
