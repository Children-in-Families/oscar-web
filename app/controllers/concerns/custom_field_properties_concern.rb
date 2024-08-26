module CustomFieldPropertiesConcern
  def find_entity
    if params[:client_id].present? && params[:client_id].to_i.zero?
      @custom_formable = Client.includes(custom_field_properties: [:custom_field]).accessible_by(current_ability).friendly.find(params[:client_id])
    elsif if params[:client_id].present?
      @custom_formable = Client.includes(custom_field_properties: [:custom_field]).accessible_by(current_ability).find(params[:client_id])
    elsif params[:family_id].present?
      @custom_formable = Family.includes(custom_field_properties: [:custom_field]).find(params[:family_id])
    elsif params[:partner_id].present?
      @custom_formable = Partner.includes(custom_field_properties: [:custom_field]).find(params[:partner_id])
    elsif params[:user_id].present?
      @custom_formable = User.includes(custom_field_properties: [:custom_field]).find(params[:user_id])
    elsif params[:community_id].present?
      @custom_formable = Community.includes(custom_field_properties: [:custom_field]).find(params[:community_id])
    end
  end
end
