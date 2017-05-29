class NgoUsageReportMailer < ApplicationMailer

  def send_report(date_time, previous_month)
    @previous_month = previous_month
    emails = ['chris@childreninfamilies.org']
    attachments["cambodian-families-usage-report-#{date_time}.xls"] = File.read(Rails.root.join("tmp/cambodian-families-usage-report-#{date_time}.xls"))
    mail(to: emails, subject: "Cambodian Families Usage Report of #{@previous_month}" )
  end
end
