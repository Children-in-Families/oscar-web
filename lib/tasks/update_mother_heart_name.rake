namespace :update_mother_heart_name do
  desc 'change mother heart cambodia to mother heart organization'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ReferralSource.where(name: "Mother's Heart Cambodia - OSCaR Referral").update_all(name: "Mother's Heart Organization - OSCaR Referral")
    end
    puts 'Done!'
  end
end
