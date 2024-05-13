module ReferralStatusConcern
  extend ActiveSupport::Concern

  included do
    after_create :update_entity_referral_status

    private

    def update_entity_referral_status
      referral = client.referrals.unsaved.last
      return unless referral

      ngo_short_name = referral.referred_from
      return if referral.non_oscar_ngo? || client.client_enrollments.any?

      if instance_of?(::ExitNgo)
        ActiveRecord::Base.connection.execute("UPDATE #{ngo_short_name}.referrals SET referral_status = 'Exited' WHERE id = #{referral.referred_from_uid}")
      else
        ActiveRecord::Base.connection.execute("UPDATE #{ngo_short_name}.referrals SET referral_status = 'Accepted' WHERE id = #{referral.referred_from_uid}")
      end
    end
  end

  class_methods do
  end
end
