every :day, :at => '00:00 am' do
  runner 'Task.upcoming_incomplete_tasks', output: 'log/whenever.log'
  # runner 'Client.ec_reminder_in(83)', output: 'log/whenever.log'
  # runner 'Client.ec_reminder_in(90)', output: 'log/whenever.log'
  runner 'Client.notify_upcoming_csi_assessment', output: 'log/whenever.log'
end

every :monday, at: '00:00 am' do
  rake 'users:remind'
end

every :month, at: '00:00 am' do
  rake 'ngo_usage_report:generate', output: 'log/whenever.log'
  # rake 'staff_monthly_report:generate', output: 'log/whenever.log'
end

every :day, at: '01:00 pm' do
  rake 'import_villages_to_cif_until_cct:start', output: 'log/whenever.log'
end

every :day, at: '01:30 pm' do
  rake 'import_villages_to_mtp_until_wmo:start', output: 'log/whenever.log'
end

every :day, at: '02:00 pm' do
  rake 'import_villages_to_agh_until_voice:start', output: 'log/whenever.log'
end

every :day, at: '02:30 pm' do
  rake 'import_villages_to_mho_until_kmr:start', output: 'log/whenever.log'
end
