class NgoUsageReportMailer < ApplicationMailer

  def send_report(date_time)
    email = 'chris@childreninfamilies.org'
    attachments["cambodian-families-usage-report-#{date_time}.xlsx"] = File.read(Rails.root.join("cambodian-families-usage-report-#{date_time}.xlsx"))
    mail(to: email, subject: 'NGO Usage Report')
  end
end
