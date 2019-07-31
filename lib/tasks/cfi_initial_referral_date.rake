namespace :cfi_initial_referral_date do
  desc 'Update client initial referral date'
  task update: :environment do
    Organization.switch_to 'cfi'

    update = CfiInitialReferralDate::Import.new('Worksheet1')
    update.initial_referral_date
  end
end
