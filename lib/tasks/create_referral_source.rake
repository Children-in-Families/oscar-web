namespace 'referral_source' do
  desc 'create referral source and import'
  task create: :environment do
    referral_sources = Organization.oscar.map { |org| "#{org.full_name} - OSCaR Referral" }
    Organization.oscar.each do |org|
      Organization.switch_to org.short_name

      referral_sources.each do |rs|
        ReferralSource.find_or_create_by(name: rs)
      end
    end
  end
end
