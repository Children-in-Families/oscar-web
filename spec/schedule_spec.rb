include Shoulda::Whenever
describe 'Scheduler' do

  describe 'A Reminder Email' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow' do
      expect(whenever).to schedule('Task.upcoming_incomplete_tasks').every(:day).at('12:00 am')
    end
  end

  describe 'Reminder exit EC on day 83' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow' do
      expect(whenever).to schedule('Client.ec_reminder_in(83)').every(:day).at('12:00 am')
    end
  end

  describe 'Reminder exit EC on day 90' do
    let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

    it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow' do
      expect(whenever).to schedule('Client.ec_reminder_in(83)').every(:day).at('12:00 am')
    end
  end
end
