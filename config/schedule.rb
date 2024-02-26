every :day, :at => '00:00 am' do
  runner 'Task.upcoming_incomplete_tasks', output: 'log/whenever.log'
  # runner 'Client.ec_reminder_in(83)', output: 'log/whenever.log'
  # runner 'Client.ec_reminder_in(90)', output: 'log/whenever.log'
  runner 'Client.notify_upcoming_csi_assessment', output: 'log/whenever.log'
  runner 'Client.notify_incomplete_daily_csi_assessment', output: 'log/whenever.log'
  runner 'Family.update_brc_aggregation_data', output: 'log/whenever.log'
end

every :monday, at: '00:00 am' do
  rake 'users:remind'
end

every :day, at: '00:00 am' do
  rake 'incompleted_assessment:delete'
  rake 'exited_client_case_worker:disattach'
  runner 'BillableAcceptedClientsWorker.perform_async'
end

every :day, at: '02:15 am' do
  rake 'notifications:cache'
end

every :hour do
  rake 'instance:update_count_data'
end

every :month, at: '00:00 am' do
  rake 'ngo_usage_report:generate', output: 'log/whenever.log'
  # rake 'staff_monthly_report:generate', output: 'log/whenever.log'
end

every :month, at: '2:00 am' do
  rake 'usage_report:build_latest', output: 'log/usage_report.log'
  rake 'monthly_billable_report', output: 'log/monthly_billable_report.log'
end
