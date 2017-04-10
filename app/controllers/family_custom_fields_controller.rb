class FamilyCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_family
  before_action :set_custom_field
  before_action :set_family_custom_field, only: [:edit, :show, :destroy]

  def index
    @family_custom_fields = @family.family_custom_fields.by_custom_field(@custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def show
  end

  def new
    @family_custom_field = @family.family_custom_fields.new(custom_field_id: @custom_field.id)
  end

  def create
    @family_custom_field                 = @family.family_custom_fields.new(family_custom_field_params)
    @family_custom_field.custom_field_id = @custom_field.id
    if @family_custom_field.save
      redirect_to family_family_custom_fields_path(@family, custom_field_id: @family_custom_field.custom_field.id), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @family_custom_field.update(family_custom_field_params)
      redirect_to family_family_custom_fields_path(@family, custom_field_id: @family_custom_field.custom_field_id), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @family_custom_field.destroy
    if @family.family_custom_fields.by_custom_field(@custom_field).empty?
      redirect_to family_path(@family), notice: t('.successfully_deleted')
    else
      redirect_to family_family_custom_fields_path(@family, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
    end
  end

  private

  def family_custom_field_params
    params.require(:family_custom_field).permit({}).merge(properties: (params['family_custom_field']['properties']).to_json)
  end

  def set_family
    @family = Family.find(params[:family_id])
  end

  def set_custom_field
    if action_name == 'edit' || action_name == 'update'
      @custom_field = @family_custom_field.custom_field
    elsif action_name == 'create'
      @custom_field = CustomField.find(params[:family_custom_field][:custom_field_id])
    else
      @custom_field = CustomField.find(params['custom_field_id'])
    end
  end

  def set_family_custom_field
    @family_custom_field = @family.family_custom_fields.find(params[:id])
  end
end
