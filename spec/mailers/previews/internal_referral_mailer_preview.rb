# Preview all emails at http://localhost:3000/rails/mailers/internal_referral_mailer
class InternalReferralMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/internal_referral_mailer/perform
  def perform
    InternalReferralMailer.perform
  end

end
