class ReferralHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in database: -> { Organization.current.mho? ? ENV['MHO_HISTORY_DATABASE_NAME'] : Rails.configuration.history_database_name }
  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: -> { Organization.current.short_name }

  def self.initial(referral)
    # create(object: referral.attributes)
  end
end
