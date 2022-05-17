namespace :ngo_usage_report do
  desc "Send Usage Report"
  task generate: :environment do
    date_time        = DateTime.now.strftime('%Y%m%d')
    ngo_usage_report = NgoUsageReport.new
    ngo_usage_report.usage_report(date_time)
  end
end
