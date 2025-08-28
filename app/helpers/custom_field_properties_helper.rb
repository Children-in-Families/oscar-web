module CustomFieldPropertiesHelper
  def custom_field_properties_edit_link(custom_field_property)
    is_custom_field_editable = is_custom_field_property_editable?(custom_field_property)
    if is_custom_field_editable && @custom_field.allowed_edit?(current_user)
      link_to edit_polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def custom_field_properties_destroy_link(custom_field_property)
    is_custom_field_editable = is_custom_field_property_editable?(custom_field_property)
    if is_custom_field_editable
      link_to polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field), method: :delete, data: { confirm: t('are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field), method: :delete, data: { confirm: t('are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def custom_field_properties_new_link
    if custom_field_editable?(@custom_field) && (client_custom_field? ? policy(@custom_formable).create? : true)
      link_to new_polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field.id) do
        content_tag :div, class: 'btn btn-outline btn-primary form-btn' do
          t('.add_new')
        end
      end
    else
      link_to_if false, new_polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field.id) do
        content_tag :div, class: 'btn btn-outline btn-primary form-btn disabled' do
          "#{t('.add_new')} #{@custom_field.form_title}"
        end
      end
    end
  end

  def client_custom_field?
    @custom_formable.class.name == 'Client'
  end

  def remove_field_prop_unicode(field_props)
    field_props['label'].gsub(/\&gt\;|\&lt\;|\&amp\;|\"/, '&lt;' => '<', '&gt;' => '>', '&amp;' => '&', '"' => '%22')
  end

  def mapping_custom_field_values(field_props)
    field_props['values'].map do |f|
      [format_placeholder(f['label']).blank? ? f['label'] : format_placeholder(f['label']), f['label'], id: "custom_field_property_properties_#{field_props['label'].gsub('"', '&qoute;').html_safe}_#{f['label'].html_safe}"]
    end
  end

  def display_custom_formable_name(klass_object)
    case klass_object.class.name.downcase
    when 'family', 'community'
      klass_object.display_name
    when 'user', 'partner'
      klass_object.name
    else
      klass_object.en_and_local_name
    end
  end

  def display_custom_formable_lebel(klass_object)
    return I18n.t('family_name') if klass_object.class.name.downcase == 'family'

    I18n.t('client_name')
  end

  private

  def form_builder_selection_options_custom_form(custom_field)
    field_types = group_field_types_custom_form(custom_field)
    @select_field_custom_form = field_types['select']
    @checkbox_field_custom_form = field_types['checkbox-group']
    @radio_field_custom_form = field_types['radio-group']
  end

  def group_field_types_custom_form(custom_field)
    group_field_types = Hash.new { |h, k| h[k] = [] }
    group_by_option_type_label = form_builder_group_by_options_type_label_custom_form(custom_field)
    group_selection_field_types = group_selection_field_types_custom_form(custom_field)
    if group_selection_field_types.present?
      group_selection_field_types&.compact.each do |selection_field_types|
        group_by_option_type_label.each do |type, labels|
          next unless labels.present?
          labels.each do |label|
            next if selection_field_types[label].blank?
            group_field_types[type] << selection_field_types[label]
          end
        end
      end
    end
    group_field_types = group_field_types.transform_values(&:flatten)
    group_field_types.transform_values(&:uniq)
  end

  def group_selection_field_types_custom_form(custom_field)
    group_value_field_types = []
    custom_field.custom_field_properties.each do |custom_field_property|
      group_value_field_types << custom_field_property.properties if custom_field_property.properties.present?
    end
    return group_value_field_types
  end

  def form_builder_group_by_options_type_label_custom_form(custom_field)
    group_options_type_label = Hash.new { |h, k| h[k] = [] }
    form_builder_option = form_builder_options_custom_form(custom_field)
    form_builder_option['type'].each_with_index do |type_option, i|
      group_options_type_label[type_option] << form_builder_option['label'][i]
    end
    group_options_type_label
  end

  def form_builder_options_custom_form(custom_field)
    form_builder_options = Hash.new { |h, k| h[k] = [] }
    custom_field.fields.each do |field|
      field.each do |k, v|
        next unless k[/^(type|label)$/i]
        form_builder_options[k] << v
      end
    end
    return form_builder_options
  end

  def is_custom_field_property_editable?(custom_field_property)
    Organization.ratanak? && !current_user.admin? ? custom_field_editable?(@custom_field) && custom_field_property.is_editable? : custom_field_editable?(@custom_field)
  end
end
