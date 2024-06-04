class EmailReferralClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(referral_from, referral_to, archived_slug)
    Organization.switch_to referral_to
    existed = Client.exists?(archived_slug: archived_slug)
    admin_emails = User.admins.non_locked.notify_email.referral_notification_email.pluck(:email)
    manager_emails = User.managers.non_locked.notify_email.referral_notification_email.pluck(:email)
    ReferralClientMailer.send_to(admin_emails, referral_from, referral_to, 'Admins', existed).deliver_now if admin_emails.any?
    ReferralClientMailer.send_to(manager_emails, referral_from, referral_to, 'Managers', existed).deliver_now if manager_emails.any?
  end
end
