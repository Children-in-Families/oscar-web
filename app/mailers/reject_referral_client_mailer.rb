class RejectReferralClientMailer < ApplicationMailer
  def client_rejection_email(staff_member, referred_to, referral)
    @referred_to = referred_to
    @staff_member = staff_member
    @client_name = referral.client_name
    @name_of_referee = referral.name_of_referee
    referee_email = User.find(referral.referee_id).email
    dev_email = ENV['DEV_EMAIL']
    mail(to: referee_email, subject: 'Referral Client Rejection', bcc: dev_email)
  end
end
