class StaffMonthlyReportMailer < ApplicationMailer

  def send_report(date_time, previous_month)
    @previous_month = previous_month
    emails    = ['chris@childreninfamilies.org', 'sam-ol@childreninfamilies.org']
    dev_email = ['sengpirun.rain@gmail.com']
    attachments["staff-monthly-report-#{date_time}.xls"] = File.read(Rails.root.join("tmp/staff-monthly-report-#{date_time}.xls"))
    mail(to: emails, subject: "Staff Monthly Report of #{@previous_month}", bcc: dev_email)
  end
end
