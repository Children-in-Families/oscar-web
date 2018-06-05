class RejectReferralClientMailer < ApplicationMailer
  def client_rejection_email(user_name, referred_to, referral)
    @referred_to = referred_to
    @user_name = user_name
    @client_name = referral.client_name
    @name_of_referee = referral.name_of_referee
    referee_email = User.find(referral.referee_id).email
    mail(to: referee_email, subject: 'Referral Client Rejection')
  end
end
