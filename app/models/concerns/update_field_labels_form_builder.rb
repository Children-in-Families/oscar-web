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
    update_labels_changed(objects, labels_changed)
    update_field_labels_changed(objects, field_labels_changed)
  end

  def update_labels_changed(objects, labels_changed)
    return if labels_changed.empty?

    labels_changed.each do |label_old, label_new|
      next if label_old == label_new

      properties = object.properties[label_new] = object.properties.delete label_old
      object.class.name.constantize.skip_callback(:save, :after, :create_client_history)
      objects.update_attributes(properties: properties)
      object.class.name.constantize.set_callback(:save, :after, :create_client_history)
    end
  end

  def update_field_labels_changed(objects, field_labels_changed)
    return if field_labels_changed.empty?
    objects.each do |object|
      field_labels_changed.each do |label_old, label_new|
        next if label_old == label_new

        form_builder_attachment = object.form_builder_attachments.file_by_name(label_old)
        form_builder_attachment.update(name: label_new) if form_builder_attachment.present?
      end
    end
  end
end
