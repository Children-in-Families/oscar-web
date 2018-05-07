include Shoulda::Whenever
describe 'Scheduler' do

  describe 'A Reminder Email' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow everyday at 00:00 am' do
      expect(whenever).to schedule('Task.upcoming_incomplete_tasks').every(:day).at('00:00 am')
    end
  end

  xdescribe 'Reminder exit EC on day 83', skip: '====== Will be reimplemented with EC CPS ======' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow everyday at 00:00 am' do
      expect(whenever).to schedule('Client.ec_reminder_in(83)').every(:day).at('00:00 am')
    end
  end

  xdescribe 'Reminder exit EC on day 90', skip: '====== Will be reimplemented with EC CPS ======' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow everyday at 00:00 am' do
      expect(whenever).to schedule('Client.ec_reminder_in(83)').every(:day).at('00:00 am')
    end
  end

  describe 'Overdue taks reminding email' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to Manager Admin and Case Worker of overdue tasks every Monday at 00:00 am' do
      expect(whenever).to schedule('users:remind').every(:monday).at('00:00 am')
    end
  end

  describe 'Cambodian Families Usage Report' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }
    it 'sends usage report every month at 00:00 am' do
      expect(whenever).to schedule('ngo_usage_report:generate').every(:month).at('00:00 am')
    end
  end
end
