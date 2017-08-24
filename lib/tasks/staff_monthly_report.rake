namespace :staff_monthly_report do
  desc "Send Subordinates Performance Report"
  task generate: :environment do
    date_time         = DateTime.now.strftime('%Y%m%d%H%M%S')
    staff_monthly_report = StaffMonthlyReportSpreadsheet.new
    staff_monthly_report.usage_report(date_time)
  end
end
