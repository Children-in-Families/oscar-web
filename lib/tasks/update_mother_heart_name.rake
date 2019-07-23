namespace :update_mother_heart_name do
  desc 'change mother heart cambodia to mother heart organization and title'
  task update: :environment do
  	Organization.find_by(short_name:'mho').update_attributes(full_name:"Mother's Heart Organisation")
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ReferralSource.where(name: "Mother's Heart Cambodia - OSCaR Referral").update_all(name: "Mother's Heart Organisation - OSCaR Referral")
    end

    Organization.switch_to 'mho'
    Setting.first.update(org_name: "Mother's Heart Organisation")
    puts 'Done!'
  end
end
