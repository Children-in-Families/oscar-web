desc 'Update client referral count for all organizations'
task update_referral_count: :environment do
  Organization.all.each do |org|
    Apartment::Tenant.switch(org.short_name) do
      Referral.received.each(&:inc_client_referral_count!)
    end
  end
end
