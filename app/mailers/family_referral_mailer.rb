class FamilyReferralMailer < ApplicationMailer
    def send_to(users, referral_from, referral_to, role, existed)
      @referral_to = referral_to
      @referral_from = referral_from
      @existed = existed
      @role = role
      mail(to: users.pluck(:email), subject: 'New referral family')
    end
  end
