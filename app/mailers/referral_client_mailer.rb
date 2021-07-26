class ReferralClientMailer < ApplicationMailer
  def send_to(users, referral_from, referral_to, role, existed)
    @referral_to = referral_to
    @referral_from = referral_from
    @existed = existed
    @role = role
    users.pluck(:email).each_slice(50).to_a.each do |emails|
      next if emails.blank?

      mail(to: emails, subject: 'New referral client')
    end
  end
end
