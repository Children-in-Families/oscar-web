class FamilyCustomFieldsController < AdminController
  before_action :set_family, :set_custom_field

  def edit
  end

  def update
    if @family_custom_field.update(merged_custom_field_params)
      redirect_to @family, notice: 'Succesfully save information'
    else
      render :edit
    end
  end

  def show
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
      @family_custom_field = @family.family_custom_fields.find(params[:id])
    end
end
