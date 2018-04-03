namespace :initial_referral_date do
  desc 'Set the Initial Referral Date to 01/01/2001 if it is blank.'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Client.where(initial_referral_date: nil).update_all(initial_referral_date: '1/1/2001')
    end
  end
end
