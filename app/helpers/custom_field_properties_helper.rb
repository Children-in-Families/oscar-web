module CustomFieldPropertiesHelper
  def custom_field_properties_edit_link(custom_formable, custom_field_property, custom_field)
    if custom_field_editable?(custom_field)
      link_to edit_polymorphic_path([custom_formable, custom_field_property], custom_field_id: custom_field) do
        content_tag :div, class: 'btn btn-outline btn-success' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_polymorphic_path([custom_formable, custom_field_property], custom_field_id: custom_field) do
        content_tag :div, class: 'btn btn-outline btn-success disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def custom_field_properties_destroy_link(custom_formable, custom_field_property, custom_field)
    # if current_user.admin?
    link_to polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field), method: :delete, data: { confirm: t('are_you_sure') } do
      content_tag :div, class: 'btn btn-outline btn-danger' do
        fa_icon('trash')
      end
    end
    # else
    #   link_to_if false, polymorphic_path([@custom_formable, custom_field_property], custom_field_id: @custom_field), method: :delete, data: { confirm: t('are_you_sure') } do
    #     content_tag :div, class: 'btn btn-outline btn-danger disabled' do
    #       fa_icon('trash')
    #     end
    #   end
    # end
  end
end