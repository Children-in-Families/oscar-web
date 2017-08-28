class ClientEnrollmentTrackingHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  protected

  def self.initial(client_enrollment_tracking)
    attributes = client_enrollment_tracking.attributes
    create(object: attributes)
  end
end
