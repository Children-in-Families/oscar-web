module CustomFieldPropertiesHelper
  def custom_field_properties_edit_link(custom_field_property)
    if custom_field_editable?(@custom_field)
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
    if custom_field_editable?(@custom_field)
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
    field = field_props['label'].gsub(/\&gt\;|\&lt\;|\&amp\;|\"/, '&lt;' => '<', '&gt;' => '>', '&amp;' => '&', '"' => '%22')
  end

  def mapping_custom_field_values(field_props)
    field_props['values'].map do |f|
      [format_placeholder(f['label']).blank? ? f['label'] : format_placeholder(f['label']), f['label'], id: "custom_field_property_properties_#{field_props['label'].gsub('"', '&qoute;').html_safe}_#{f['label'].html_safe}"]
    end
  end
end
