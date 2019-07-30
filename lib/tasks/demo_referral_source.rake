namespace :demo_oscar_referral do
  desc "delete demo oscar referral from all instances"
  task delete: :environment do |task, args|
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      ReferralSource.find_by(name: 'Demo - OSCaR Referral').delete if ReferralSource.find_by(name: 'Demo - OSCaR Referral').present?
      ReferralSource.find_by(name: 'OSCaR - OSCaR Referral').delete if ReferralSource.find_by(name: 'OSCaR - OSCaR Referral').present?
    end
    puts 'Done updating!!!'
  end
end
