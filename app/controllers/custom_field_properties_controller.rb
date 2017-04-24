class CustomFieldPropertiesController < AdminController
  load_and_authorize_resource

  before_action :find_entity
  before_action :find_custom_field

  def index
    @custom_field_properties = @custom_formable.custom_field_properties.by_custom_field(@custom_field).most_recents.page(params[:page]).per(4)
    # redirect_to client_path(@client) if @client_custom_fields.blank?
  end

  def new
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_id: @custom_field)
  end

  def create
    @custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
    if @custom_field_property.save
      redirect_to polymorphic_path([@custom_formable, CustomFieldProperty], custom_field_id: @custom_field), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def custom_field_property_params
    params.require(:custom_field_property).permit({}).merge(properties: (params['custom_field_property']['properties']), custom_field_id: params[:custom_field_id])
  end

  def find_custom_field
    @custom_field = CustomField.find(params[:custom_field_id])
  end

  def find_entity
    if params[:client_id].present?
      @custom_formable = Client.friendly.find(params[:client_id])
    elsif params[:user_id].present?

    elsif params[:family_id].present?

    elsif params[:partner_id].present?

    end
  end

end
