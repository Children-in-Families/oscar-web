class CaseWorkerClientOffline
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  store_in collection: ENV['CASE_WORKER_CLIENT_OFFLINE_DATABASE'], database: ENV['HISTORY_DATABASE_NAME']
  default_scope { where(tenant: Organization.current.try(:short_name)) }

  field :tenant, type: String, default: ->{ Organization.current.short_name }
  field :slug_id, type: String
  field :object, type: Hash

  def self.initial(client)
    Mongoid.raise_not_found_error = false
    attributes = client.attributes
    attributes = attributes.merge('assessments' => client.assessments.map { |a| a.attributes} )
    attributes = attributes.merge('case_notes' => client.case_notes.map { |c| c.attributes } )
    attributes = attributes.merge('tasks' => client.tasks.map { |t| t.attributes} )
    attributes_client_enrollments = client.client_enrollments.map { |ce| ce.attributes}
    attributes_custom_formable = client.custom_field_properties.map { |cfp| cfp.attributes}

    attributes_client_enrollments.map do |attr|
      old_keys = attr["properties"].keys
      new_keys = attr["properties"].keys.map do |key|
        key.gsub('.', '[dot]').gsub('$', '[dollar]')
      end
      keys = Hash[old_keys.zip new_keys]
      attr["properties"].transform_keys! {|k| keys[k]}
    end

    attributes_custom_formable.map do |attr|
      old_keys = attr["properties"].keys
      new_keys = attr["properties"].keys.map do |key|
        key.gsub('.', '[dot]').gsub('$', '[dollar]')
      end
      keys = Hash[old_keys.zip new_keys]
      attr["properties"].transform_keys! {|k| keys[k]}
    end

    attributes = attributes.merge('client_enrollments' => attributes_client_enrollments)
    attributes = attributes.merge('custom_formable' => attributes_custom_formable)
    create(object: attributes, slug_id: client.archived_slug)
  end
end