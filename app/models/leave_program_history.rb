class LeaveProgramHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :object, type: Hash
  field :tenant, type: String, default: ->{ Organization.current.short_name }

  protected

  def self.initial(leave_program)
    attributes = leave_program.attributes
    attributes['properties'] = format_property(attributes)
    create(object: attributes)
  end

  def self.format_property(attributes)
    mappings = {}
    attributes['properties'].each do |k, v|
      mappings[k] = k.gsub(/(\s|[.])/, '_')
    end
    attributes['properties'].map {|k, v| [mappings[k].downcase, v] }.to_h
  end
end
