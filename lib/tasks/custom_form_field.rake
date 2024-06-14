namespace :custom_form_field do
  desc "Migrate local label and values for custom field/form"
  task migrate: :environment do
    Organization.without_shared.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name

      ProgramStream.paper_trail.disable
      ProgramStream.all.each do |program_stream|
        enrollment = populate_local_fields(program_stream.enrollment)
        exit_program = populate_local_fields(program_stream.exit_program)
        program_stream.enrollment = enrollment
        program_stream.exit_program = exit_program
        program_stream.save
      end
      ProgramStream.paper_trail.enable

      Tracking.paper_trail.disable
      Tracking.all.each do |tracking|
        fields = populate_local_fields(tracking.fields)
        tracking.fields = fields
        tracking.save
      end
      Tracking.paper_trail.enable

      CustomField.paper_trail.disable
      CustomField.all.each do |custom_field|
        custom_field.paper_trail.without_versioning do
          fields = populate_local_fields(custom_field.fields)
          custom_field.fields = fields
          custom_field.save
        end
      end
      CustomField.paper_trail.enable
    end
  end
end

def populate_local_fields(fields)
  fields.map do |field_hash|
    if field_hash.has_key?('local_label')
      field_hash
    elsif field_hash.has_key?('values')
      field_hash.merge('local_label' => field_hash['label'], 'values' => field_hash['values'].map{|values| values.merge('local_value' => values['value'], 'local_label' => values['label']) })
    else
      field_hash.merge('local_label' => field_hash['label'])
    end
  end
end

def without_papertrail
  PaperTrail.disable
  yield if block_given?
  PaperTrail.enable
end
