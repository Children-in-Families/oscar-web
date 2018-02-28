namespace :two_factor_auth do
  desc "Generate Two Factor Authentication Key for users"
  task generate: :environment do
    Organization.all.each do |org|
      Organization.switch_to(org.short_name)
      User.all.each do |user|
        user.otp_secret = User.generate_otp_secret
        user.save!
      end
    end
  end
end
