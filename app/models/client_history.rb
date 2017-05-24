class ClientHistory
  include Mongoid::Document

  default_scope { where(tenant: Organization.current.short_name) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  def self.initial(obj)
    create(object: obj.attributes)
    binding.pry
  end
end

# where('object.id' => 815).first