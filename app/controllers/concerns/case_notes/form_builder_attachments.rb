module CaseNotes
  module FormBuilderAttachments
    def attach_custom_field_files
      return unless attachment_params.present?

      attachment_params.each do |_k, attachment|
        name = attachment['name']
        next if name.blank? || attachment['file'].blank?

        form_builder_attachment = @case_note.custom_field_property.form_builder_attachments.file_by_name(name)
        if form_builder_attachment.nil?
          @case_note.custom_field_property.form_builder_attachments.create(name: name, file: attachment[:file])
        else
          modify_files = form_builder_attachment.file
          modify_files += attachment['file']

          form_builder_attachment = @case_note.custom_field_property.form_builder_attachments.file_by_name(name)
          form_builder_attachment.file = modify_files
          form_builder_attachment.save
        end
      end
    end

    def delete_form_builder_attachment(resource, name, index)
      attachment = resource.get_form_builder_attachment(name)
      remain_file = attachment.file
      deleted_file = remain_file.delete_at(index)
      deleted_file.try(:remove_images!)
      remain_file.empty? ? attachment.remove_file! : attachment.file = remain_file
      attachment.save
    end

    def attachment_params
      return {} if params.dig(:case_note, :custom_field_property_attributes, :form_builder_attachments_attributes).blank?

      params[:case_note][:custom_field_property_attributes][:form_builder_attachments_attributes]
    end
  end
end
