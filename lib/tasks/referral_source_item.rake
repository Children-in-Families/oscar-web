namespace :community do
  desc "add community to referral source category"
  task create: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      ReferralSource.find_or_create_by(name: 'សហគមន៍', name_en: 'Community')
      ReferralSource.find_or_create_by(name: 'ព្រះវិហារ', name_en: 'Church')
    end
  end
end
