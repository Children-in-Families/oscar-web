class EnterNgoUserHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :tenant, type: String, default: ->{ Organization.current.short_name }
  field :object, type: Hash

  embedded_in :enter_ngo_history
end
