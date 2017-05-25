namespace :ngo_usage_report do
  desc "Remind Case Worker incomplete overdue tasks weekly"
  task generate: :environment do
    date_time = DateTime.now.strftime('%Y%m%d%H%M%S')
    NgoUsageReport.new(date_time)
  end
end
