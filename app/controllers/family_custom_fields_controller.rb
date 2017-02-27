class FamilyCustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_family
  before_action :set_custom_field, only: [:new, :index, :destroy]
  before_action :set_family_custom_field, only: [:edit, :show, :destroy]

  def edit
  end

  def update
    if @family_custom_field.update(merged_custom_field_params)
      redirect_to family_family_custom_field_path(@family, @family_custom_field), notice: t('.successfully_created')
    else
      render :edit
    end
  end

  def show
  end

  def new
    @family_custom_field = FamilyCustomField.new(custom_field: @custom_field, family: @family)
    @family_custom_field.save
  end

  def index
    @family_custom_field = @family.family_custom_fields.where(custom_field: @custom_field).order(created_at: :desc).page(params[:page]).per(4)
  end

  def destroy
    @family_custom_field.destroy
    redirect_to family_family_custom_fields_path(@family, custom_field_id: @custom_field.id), notice: t('.successfully_deleted')
  end

  private
    def custom_field_params
      params.require(:family_custom_field).permit(:properties)
    end

    def merged_custom_field_params
      if params['family_custom_field']['properties'].present?
        custom_field_params.merge(properties: (params['family_custom_field']['properties']).to_json)
      else
        custom_field_params
      end
    end

  protected
    def set_family
      @family = Family.find(params[:family_id])
    end

    def set_custom_field
      @custom_field = CustomField.find(params['custom_field_id'])
    end

    def set_family_custom_field
      @family_custom_field = @family.family_custom_fields.find(params[:id])
    end
end
