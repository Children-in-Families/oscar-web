class ReferralClientMailer < ApplicationMailer
  def send_to(users, referral_from, referral_to, role, existed)
    @referral_to = referral_to
    @referral_from = referral_from
    @existed = existed
    @role = role
    dev_email = ENV['DEV_EMAIL']
    mail(to: users.pluck(:email), subject: 'New referral client', bcc: dev_email)
  end
end
