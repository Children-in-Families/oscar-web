namespace :ngo_usage_report do
  desc "Send Usage Report"
  task generate: :environment do
    date_time        = DateTime.now.strftime('%Y%m%d%H%M%S')
    ngo_usage_report = NgoUsageReport.new
    ngo_usage_report.usage_report(date_time)

    sleep 3

    date_time        = DateTime.now.strftime('%Y%m%d%H%M%S')
    old_ngo_user_report = OldNgoUsageReport.new
    old_ngo_user_report.usage_report(date_time)
  end
end
