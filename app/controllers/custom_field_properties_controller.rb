class CustomFieldPropertiesController < AdminController
  load_and_authorize_resource

  include CustomFieldPropertiesConcern
  include FormBuilderAttachments

  before_action :find_entity, :find_custom_field
  before_action :find_custom_field_property, only: [:edit, :update, :destroy]
  before_action :authorize_client, :check_new_create_permission, only: [:new, :create]
  before_action :get_form_builder_attachments, only: [:edit, :update]
  before_action -> { check_user_permission('editable') }, except: [:index, :show]
  before_action -> { check_user_permission('readable') }, only: [:show, :index]

  def index
    @custom_field_properties = @custom_formable.custom_field_properties.includes(:custom_formable).accessible_by(current_ability).by_custom_field(@custom_field).most_recents.page(params[:page]).per(4)
  end

  def new
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_id: @custom_field)
    @attachments = @custom_field_property.form_builder_attachments
  end

  def edit
  end

  def create
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
    @custom_field_property.user_id = current_user.id
    if @custom_field_property.save
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @custom_field_property.update_attributes(custom_field_property_params)
      add_more_attachments(@custom_field_property)
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    name = params[:file_name]
    index = params[:file_index].to_i
    if name.present? && index.present?
      if name == 'attachments'
        delete_custom_field_property_attachments(index)
      else
        delete_form_builder_attachment(@custom_field_property, name, index)
      end
      redirect_to request.referer, notice: t('.delete_attachment_successfully')
    else
      @custom_field_property.destroy
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_deleted')
    end
  end

  private

  def custom_field_property_params
    if properties_params.present?
      mappings = {}
      properties_params.each do |k, _|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = properties_params.map { |k, v| [mappings[k], v] }.to_h
      formatted_params.values.map { |v| v.delete('') if (v.is_a? Array) && v.size > 1 }
    end
    default_params = params.require(:custom_field_property).permit({}).merge(custom_field_id: params[:custom_field_id])
    default_params = default_params.merge(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge(form_builder_attachments_attributes: attachment_params) if action_name == 'create' && attachment_params.present?
    default_params
  end

  def delete_custom_field_property_attachments(index)
    attachments = @custom_field_property.attachments
    deleted_file = attachments.delete_at(index)
    deleted_file.try(:remove_attachments!)
    attachments.empty? ? @custom_field_property.remove_attachments! : @custom_field_property.attachments = attachments
    @custom_field_property.save
  end

  def get_form_builder_attachments
    @attachments = @custom_field_property.form_builder_attachments
  end

  def find_custom_field_property
    @custom_field_property = @custom_formable.custom_field_properties.find(params[:id])
  end

  def authorize_client
    return true if current_user.admin?
    authorize @custom_formable if @custom_formable.class.name == 'Client'
  end

  def find_custom_field
    @custom_field = CustomField.find_by(entity_type: @custom_formable.class.name, id: params[:custom_field_id])
    raise ActionController::RoutingError.new('Not Found') if @custom_field.nil?
  end

  def check_user_permission(permission)
    unless current_user.admin? || current_user.strategic_overviewer?
      permission_set = current_user.custom_field_permissions.find_by(custom_field_id: @custom_field)[permission]
      redirect_to root_path, alert: t('unauthorized.default') unless permission_set
    end
  end

  def check_new_create_permission
    return unless current_user.case_worker?
    redirect_to root_path, alert: t('unauthorized.default') if @custom_field.hidden
  end

end
