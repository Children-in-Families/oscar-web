class ClientEnrollmentHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  protected

  def self.initial(client_enrollment)
    attributes = client_enrollment.attributes
    create(object: attributes)
  end
end
