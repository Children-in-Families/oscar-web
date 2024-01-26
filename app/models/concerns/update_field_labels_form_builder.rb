module UpdateFieldLabelsFormBuilder
  def labels_update(new_fields, old_fields, objects)
    labels_changed = []
    field_labels_changed = []
    old_fields = [] if old_fields.empty?
    fields_changed = new_fields - old_fields
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
    constant_name = objects.compact.first.class.name.constantize
    return if constant_name == NilClass || constant_name.nil? || (labels_changed.empty? || labels_changed.all? { |label_old, label_new| label_old == label_new })

    constant_name.paper_trail.disable
    objects.each_slice(1000).with_index do |batch_custom_field_properties, i|
      values = batch_custom_field_properties.map do |object|
        labels_changed.each do |label_old, label_new|
          next if label_old == label_new

          object.properties[label_new] = object.properties.delete label_old
        end

        { id: object.id, properties: object.properties }
      end

      grouped_custom_field_properties = values.index_by { |value| value[:id] }
      # ActiveRecord::Base.connection.execute("UPDATE custom_field_properties SET properties = mapping_values.properties FROM (VALUES #{values}) AS mapping_values (custom_field_properties_id, properties) WHERE custom_field_properties.id = mapping_values.custom_field_properties_id") if values.present?
      constant_name.update(grouped_custom_field_properties.keys, grouped_custom_field_properties.values)
    end
    constant_name.paper_trail.enable
  end

  def update_field_labels_changed(objects, field_labels_changed)
    return if field_labels_changed.empty?
    objects.compact.each do |object|
      field_labels_changed.each do |label_old, label_new|
        next if label_old == label_new

        form_builder_attachment = object.form_builder_attachments.file_by_name(label_old)
        form_builder_attachment.update(name: label_new) if form_builder_attachment.present?
      end
    end
  end
end
