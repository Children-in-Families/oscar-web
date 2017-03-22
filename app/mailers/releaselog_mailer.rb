class ReleaselogMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def notify_admins(admin_emails)
    mail(to: admin_emails, subject: 'There Is A New Release Today')
  end
end
