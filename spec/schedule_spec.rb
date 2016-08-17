include Shoulda::Whenever

describe 'A Reminder Email' do
  let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, 'config', 'schedule.rb').to_s) }

  it 'sends to caseworkers of their incomplete upcoming tasks due tomorrow' do
    expect(whenever).to schedule('Task.upcoming_incomplete_tasks').every(:day).at('12:00 am')
  end
end