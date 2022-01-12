namespace :referral_source_test do
  desc "Remove test referral sources in every NGO"
  task remove: :environment do
    referral_sources = ['demo-123 - OSCaR Referral', 'Bahamas Red Cross - OSCaR Referral', 'demo-00001 - OSCaR Referral', 'MDTEST - OSCaR Referral', 'Monitoring and Evaluation Dashboard - OSCaR Referral', 'Sokly  - OSCaR Referral', 'Friend International - OSCaR Referral', 'Children Fund', 'Open Arms Organization', 'ICF - OSCaR Referral', 'ម្តាយ', 'Women NOG', "Mother's Heart Organization - OSCaR Referral"]
    Organization.without_shared.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name
      ReferralSource.where(name: referral_sources).each do |referral_source|
        next if referral_source.clients.any?
        referral_source.destroy
      end
    end
  end

end
