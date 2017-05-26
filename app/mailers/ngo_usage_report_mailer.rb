class NgoUsageReportMailer < ApplicationMailer

  def send_report(date_time)
    email = ENV['USAGE_REPORT_EMAIL']
    attachments["cambodian-families-usage-report-#{date_time}.xlsx"] = File.read(Rails.root.join("tmp/usage_report/cambodian-families-usage-report-#{date_time}.xlsx"))
    mail(to: email, subject: 'NGO Usage Report')
  end
end
