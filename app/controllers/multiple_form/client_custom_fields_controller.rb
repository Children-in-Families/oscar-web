class MultipleForm::ClientCustomFieldsController < AdminController
  include FormBuilderAttachments

  def new
    @custom_field = CustomField.client_forms.find(params[:custom_field_id])
    @clients = Client.accessible_by(current_ability).active_accepted_status
    @custom_field_property = CustomFieldProperty.new(custom_formable_type: "Client")
  end

  def create
    @custom_field = CustomField.find(params[:custom_field_id])
    clients = Client.where(slug: params['custom_field_property']['clients'])
    clients.each do |client|
      @custom_field_property = client.custom_field_properties.new(custom_field_property_params)
      @custom_field_property.user_id = current_user.id
      if @custom_field_property.valid?
        @custom_field_property.save
      else
        break
      end
    end
    unless @custom_field_property.valid?
      @clients = Client.accessible_by(current_ability).active_accepted_status
      @selectd_clients = clients.pluck(:slug)
      render :new
    else
      if  params[:confirm] == 'true'
        redirect_to new_multiple_form_custom_field_client_custom_field_path(@custom_field), notice: t('.successfully_created')
      else
        redirect_to root_path, notice: t('.successfully_created')
      end
    end
  end

  def custom_field_property_params
    if properties_params.present?
      mappings = {}
      properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = properties_params.map {|k, v| [mappings[k], v] }.to_h
      formatted_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }
    end
    default_params = params.require(:custom_field_property).permit({}).merge(custom_field_id: params[:custom_field_id])
    default_params = default_params.merge(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge(form_builder_attachments_attributes: attachment_params) if attachment_params.present?
    default_params
  end
end
