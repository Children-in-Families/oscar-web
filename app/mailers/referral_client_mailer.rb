class ReferralClientMailer < ApplicationMailer
  def send_to(emails, referral_from, referral_to, role, existed)
    @referral_to = referral_to
    @referral_from = referral_from
    @existed = existed
    @role = role
    emails.each_slice(50).to_a.each do |mails|
      next if mails.blank?

      mail(to: mails.join(', '), subject: 'New referral client')
    end
  end
end
