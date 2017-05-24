class NgoUsageReportMailer < ApplicationMailer

  def send_report
    email = 'chris@childreninfamilies.org'
    attachments['ngo_usage_report.xlsx'] = File.read(Rails.root.join('tmp/test.xlsx'))
    mail(to: email, subject: 'NGO Usage Report')
  end
end
