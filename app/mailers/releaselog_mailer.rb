class ReleaselogMailer < ActionMailer::Base
  default from: 'info@cambodianfamilies.com'

  def notify_admins(admin_emails)
    mail(to: admin_emails, subject: 'There is a new release today')
  end
end
