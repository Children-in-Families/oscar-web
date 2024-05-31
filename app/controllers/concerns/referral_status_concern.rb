module ReferralStatusConcern
  extend ActiveSupport::Concern

  included do
    after_create :update_entity_referral_status

    private

    def update_entity_referral_status
      referral = client.referrals.last
      return unless referral

      ngo_short_name = referral.referred_from

      sql = " AND (SELECT COUNT(*) from #{ngo_short_name}.referrals WHERE slug = '#{referral.slug}' AND referred_to = '#{Apartment::Tenant.current}') <= 1"
      if instance_of?(::ExitNgo)
        ActiveRecord::Base.connection.execute("UPDATE #{ngo_short_name}.referrals SET referral_status = 'Exited' WHERE id = #{referral.referred_from_uid} #{sql}")
      else
        ActiveRecord::Base.connection.execute("UPDATE #{ngo_short_name}.referrals SET referral_status = 'Accepted' WHERE id = #{referral.referred_from_uid} #{sql}")
      end
    end
  end

  class_methods do
  end
end
