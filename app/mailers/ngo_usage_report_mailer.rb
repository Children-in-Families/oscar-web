class NgoUsageReportMailer < ApplicationMailer
  def send_report(date_time, previous_month)
    @previous_month = previous_month
    emails    = [ENV['CIF1_EMAIL'], ENV['CIF2_EMAIL']]
    dev_email = ENV['DEV_EMAIL']
    attachments["OSCaR-usage-report-#{date_time}.xls"] = File.read(Rails.root.join("tmp/OSCaR-usage-report-#{date_time}.xls"))
    mail(to: emails, subject: "OSCaR Usage Report of #{@previous_month}", bcc: dev_email)
  end
end
