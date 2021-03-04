class EntityEnrollmentTrackingHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  include HistoryConcern

  store_in database: ->{ Organization.current.mho? ? ENV['MHO_HISTORY_DATABASE_NAME'] : ENV['HISTORY_DATABASE_NAME'] }
  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  protected

  def self.initial(entity_enrollment_tracking)
    attributes = entity_enrollment_tracking.attributes
    attributes['properties'] = format_property(attributes)
    create(object: attributes)
  end
end
