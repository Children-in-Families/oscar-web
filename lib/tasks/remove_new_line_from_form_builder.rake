namespace :remove_new_line_form_form_builder do
  desc 'Remove new line (\n) from form builder'

  task start: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      CustomField.all.each do |custom_field|
        next if custom_field.fields.blank?
        custom_field.fields.each do |field|
          field['label'] = delete_new_line(field['label'])
        end
        custom_field.save
      end

      ProgramStream.all.each do |program|
        program.enrollment.each do |field|
          field['label'] = delete_new_line(field['label'])
        end

        program.exit_program.each do |field|
          field['label'] = delete_new_line(field['label'])
        end

        program.save
      end

      Tracking.all.each do |tracking|
        next if tracking.fields.blank?
        tracking.fields.each do |field|
          field['label'] = delete_new_line(field['label'])
        end
        tracking.save
      end
    end
  end

  private

  def delete_new_line(field_label)
    field_label.delete("\n") if field_label.present?
  end
end
