every :day, :at => '12:00 am' do
  runner 'Task.upcoming_incomplete_tasks', output: 'log/whenever.log'
end
