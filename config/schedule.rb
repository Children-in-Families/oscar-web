every :day, :at => '7:00 am' do
  runner 'Task.upcoming_incomplete_tasks', output: 'log/whenever.log'
  runner 'Client.ec_reminder_in(83)', output: 'log/whenever.log'
  runner 'Client.ec_reminder_in(90)', output: 'log/whenever.log'
end

every :monday, at: '7:00 am' do
  rake 'users:remind'
end

every :month, at: '7:00 am' do
  rake 'ngo_usage_report:generate', output: 'log/whenever.log'
end
