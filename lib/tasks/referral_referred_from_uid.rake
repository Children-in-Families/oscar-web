namespace :referral_referred_from_uid do
  desc 'Migrate Referral ID to target NGOs'
  task migrate: :environment do
    Organization.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name

      Referral.where(referred_from: short_name).each do |referral|
        referral_id = referral.id
        referral_date = referral.date_of_referral
        client_slug = referral.slug
        target_ngo = referral.referred_to
        next unless Organization.find_by(short_name: target_ngo).present?

        ActiveRecord::Base.connection.execute("UPDATE #{target_ngo}.referrals SET referred_from_uid = #{referral.id} WHERE slug = '#{client_slug}' AND date_of_referral = '#{referral_date}'")
      end
    end
  end
end
