class RejectReferralFamilyMailer < ApplicationMailer
  def family_rejection_email(staff_member, referred_to, referral)
    @referred_to = referred_to
    @staff_member = staff_member
    @family_name = referral.name_of_family
    @name_of_referee = referral.name_of_referee
    referee_email = User.non_locked.notify_email.find_by(id: referral.referee_id).try(:email)
    mail(to: referee_email, subject: 'Referral Family Rejection')
  end
end
