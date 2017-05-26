class NgoUsageReportMailer < ApplicationMailer

  def send_report(date_time)
    email = ENV['USAGE_REPORT_EMAIL']
    attachments["cambodian-families-usage-report-#{date_time}.xls"] = File.read(Rails.root.join("tmp/usage_report/cambodian-families-usage-report-#{date_time}.xls"))
    mail(to: email, subject: 'Cambodian Families Usage Report')
  end
end
