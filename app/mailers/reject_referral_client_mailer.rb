class RejectReferralClientMailer < ApplicationMailer
  def client_rejection_email(users, referred_to, client_name, user_name, role)
    @referred_to = referred_to
    @client_name = client_name
    @user_name = user_name
    @role = role.pluralize(users.count)
    mail(to: users.pluck(:email), subject: 'Referral Client Rejection')
  end
end
