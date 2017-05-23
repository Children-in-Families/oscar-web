class CustomFieldPropertiesController < AdminController
  load_and_authorize_resource

  before_action :find_entity, :find_custom_field
  before_action :find_custom_field_property, only: [:edit, :update, :destroy]

  def index
    @custom_field_properties = @custom_formable.custom_field_properties.accessible_by(current_ability).by_custom_field(@custom_field).most_recents.page(params[:page]).per(4)
  end

  def new
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_id: @custom_field)
    authorize! :new, @custom_field_property
  end

  def edit
    authorize! :edit, @custom_field_property
  end

  def create
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
    authorize! :create, @custom_field_property
    if @custom_field_property.save
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    authorize! :update, @custom_field_property
    add_more_attachments(params['custom_field_property']['attachments'])
    if @custom_field_property.update_attributes(custom_field_property_params) && @custom_field_property.save
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @custom_field_property
    if params[:file_index].present?
      remove_attachment_at_index(params[:file_index].to_i)
      message = "Failed deleting attachment" unless @custom_field_property.save
    else
      @custom_field_property.destroy
    end
    flash_alert = message.present? ? message : t('.successfully_deleted')
    respond_to do |f|
      f.html { redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: flash_alert }
      f.json { render json: { message: flash_alert }, status: '200' }
    end
  end

  private

  def custom_field_property_params
    default_params = params.require(:custom_field_property).permit({}).merge(properties: (params['custom_field_property']['properties']), custom_field_id: params[:custom_field_id])
    default_params = default_params.merge(attachments: (params['custom_field_property']['attachments'])) if action_name == 'create'
    default_params



    # params.require(:custom_field_property).permit({}).merge(properties: (params['custom_field_property']['properties']), attachments: (params['custom_field_property']['attachments']), custom_field_id: params[:custom_field_id])
  end

  def find_custom_field_property
    @custom_field_property = @custom_formable.custom_field_properties.find(params[:id])
  end

  def find_custom_field
    @custom_field = CustomField.find_by(entity_type: @custom_formable.class.name, id: params[:custom_field_id])
    raise ActionController::RoutingError.new('Not Found') if @custom_field.nil?
  end

  def find_entity
    if params[:client_id].present?
      @custom_formable = Client.accessible_by(current_ability).friendly.find(params[:client_id])
    elsif params[:family_id].present?
      @custom_formable = Family.find(params[:family_id])
    elsif params[:partner_id].present?
      @custom_formable = Partner.find(params[:partner_id])
    elsif params[:user_id].present?
      @custom_formable = User.find(params[:user_id])
    end
  end

  def add_more_attachments(new_files)
    files = @custom_field_property.attachments 
    files += new_files
    @custom_field_property.attachments = files
  end

  def remove_attachment_at_index(index)
    remain_attachment = @custom_field_property.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove!)
    remain_attachment.empty? ? @custom_field_property.remove_attachments! : (@custom_field_property.attachments = remain_attachment )
  end
end
