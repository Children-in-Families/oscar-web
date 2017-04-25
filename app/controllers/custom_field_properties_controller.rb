class CustomFieldPropertiesController < AdminController
  load_and_authorize_resource

  before_action :find_entity
  before_action :find_custom_field
  before_action :find_custom_field_property, only: [:edit, :update, :destroy]

  def index
    @custom_field_properties = @custom_formable.custom_field_properties.by_custom_field(@custom_field).most_recents.page(params[:page]).per(4)
  end

  def new
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_id: @custom_field)
  end

  def edit
  end

  def create
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
    if @custom_field_property.save
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @custom_field_property.update_attributes(custom_field_property_params)
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @custom_field_property.destroy
    redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_deleted')
  end

  private

  def custom_field_property_params
    params.require(:custom_field_property).permit({}).merge(properties: (params['custom_field_property']['properties']), custom_field_id: params[:custom_field_id])
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
      @custom_formable = Client.friendly.find(params[:client_id])
    elsif params[:family_id].present?
      @custom_formable = Family.find(params[:family_id])
    elsif params[:partner_id].present?
      @custom_formable = Partner.find(params[:partner_id])
    elsif params[:user_id].present?

    end
  end

end
