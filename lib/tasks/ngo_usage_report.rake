namespace :ngo_usage_report do
  desc "Remind Case Worker incomplete overdue tasks weekly"
  task generate: :environment do
    date_time = DateTime.now.strftime('%Y%m%d%H%M%S')
    ngo_usage_report = NgoUsageReport.new
    ngo_usage_report.usage_report(date_time)
  end
end
