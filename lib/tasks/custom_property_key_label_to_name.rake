namespace :custom_property_key_label_to_name do
  desc "Update all custom properties' keys replace label value with name value"
  task update: :environment do
    # ClientEnrollment.skip_callback(:save, :after, :create_client_enrollment_history)
    # ClientEnrollment.where(id: 15).each do |client_enrollment|
    #   new_props = {}
    #   client_enrollment_properties = client_enrollment.properties
    #   program_stream_enrollment_properties = client_enrollment.program_stream.enrollment
    #   program_stream_enrollment_properties.each do |prop|
    #     new_props[prop_name] = set_new_props(prop, client_enrollment_properties)
    #   end
    #   client_enrollment.properties = new_props
    #   client_enrollment.save(validate: false)
    # end

    Organization.pluck(:short_name).each do |short_name|
      next unless short_name == 'cif'

      Organization.switch_to short_name
      ClientEnrollmentTracking.skip_callback(:save, :after, :create_client_enrollment_tracking_history)
      ClientEnrollmentTracking.all.map do |client_enrolllment_tracking|
        new_props = {}
        client_enrolllment_tracking_props = client_enrolllment_tracking.properties
        tracking = client_enrolllment_tracking.tracking
        next if tracking.nil?

        tracking_fields = tracking.fields
        tracking_fields.each do |field|
          prop_name = field['name']
          new_props[prop_name] = set_new_props(field, client_enrolllment_tracking_props)
        end

        ActiveRecord::Base.connection.execute("UPDATE #{short_name}.client_enrollment_trackings SET properties = '#{new_props.to_json}' WHERE id = #{client_enrolllment_tracking.id}")
      end
    end
  end
end

def set_new_props(prop, properties)
  prop_label = prop['label']
  return properties[prop_label] unless properties[prop_label].is_a?(String)

  properties[prop_label].gsub("'", "''")
end
