namespace :update_compasio do
  desc 'Update slug prefix and org info'
  task update: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      referral_source = ReferralSource.find_by(name: 'Compasio - OSCaR Referral')
      referral_source.update_attributes(name: 'Global Child Advocates - OSCaR Referral') if referral_source.present?

      referrals = Referral.where('slug ILIKE ?', '%cps%').or(Referral.where(referred_to: 'cps')).or(Referral.where(referred_from: 'cps'))

      referrals.each do |referral|
        referral.slug           = referral.slug.gsub('cps', 'gca')
        referral.referred_to    = referral.referred_to.gsub('cps', 'gca')
        referral.referred_from  = referral.referred_from.gsub('cps', 'gca')
        referral.save(validate: false)
      end

      if org.short_name == 'shared'
        SharedClient.where('slug ILIKE ?', '%cps%').each do |client|
          client.slug = client.slug.gsub('cps', 'gca')
          client.save(validate: false)
        end
      else
        Client.where('slug ILIKE ?', '%cps%').each do |client|
          client.slug = client.slug.gsub('cps', 'gca')
          client.save(validate: false)
        end
      end
    end

    puts 'Updated Client IDs!'

    Organization.switch_to 'cps'
    org = Organization.current
    org.full_name  = 'Global Child Advocates'
    org.short_name = 'gca'
    org.save

    puts 'Updated NGO Info!'
  end
end
