module UpdateFieldLabelsFormBuilder
  def labels_update(new_fields, old_fields, objects)
    labels_changed = []
    field_labels_changed = []
    fields_changed =  new_fields - old_fields
    fields_changed.each do |field_changed|
      old_fields.each do |entity|
        if entity['name'] == field_changed['name']
          if entity['type'] == 'file'
            field_labels_changed << [entity['label'], field_changed['label']]
          else
            labels_changed << [entity['label'], field_changed['label']]
          end
        end
      end
    end
    return if labels_changed.empty? && field_labels_changed.empty?
    objects.each do |object|
      if labels_changed.present?
        labels_changed.each do |label_old, label_new|
          object.properties[label_new] = object.properties.delete label_old
        end
        object.save
      end
      if field_labels_changed.present?
        field_labels_changed.each do |label_old, label_new|
          form_builder_attachment = object.form_builder_attachments.file_by_name(label_old)
          form_builder_attachment.update(name: label_new) if form_builder_attachment.present?
        end
      end
    end
  end
end
