# namespace :two_factor_auth do
#   desc "Generate Two Factor Authentication Key for users"
#   task generate: :environment do
#     Organization.all.each do |org|
#       Organization.switch_to(org.short_name)
#       User.where(otp_secret_key: nil).each { |user| user.update_attribute(:otp_secret_key, ROTP::Base32.random_base32) }
#     end
#   end
# end
