class NgoUsageReportMailer < ApplicationMailer

  def send_report(date_time, previous_month)
    @previous_month = previous_month
    email = ENV['USAGE_REPORT_EMAIL']
    attachments["cambodian-families-usage-report-#{date_time}.xls"] = File.read(Rails.root.join("tmp/usage_report/cambodian-families-usage-report-#{date_time}.xls"))
    mail(to: email, subject: "Cambodian Families Usage Report of #{@previous_month}" )
  end
end
