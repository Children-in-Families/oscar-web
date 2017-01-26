class FormBuilder::CustomFieldsController < AdminController
  before_action :set_custom_field, only: [:edit, :update, :destroy]

  def index
    @custom_fields = CustomField.all
  end

  def new
    @custom_field = CustomField.new
  end

  def create
    @custom_field = CustomField.new(custom_field_params)
    if @custom_field.save
      redirect_to custom_fields_path, notice: 'Successfully created a custom fields'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to custom_fields_path, notice: 'Successfully update a custom field'
    else
      render :edit
    end
  end

  def destroy
    if @custom_field.destroy
      redirect_to custom_fields_path, notice: 'Successfully deleted a custom field'
    else
      redirect_to custom_fields_path, alert: 'Failed to delete a custom field'
    end
  end

  private
    def custom_field_params
      params.require(:custom_field).permit(:entity_name, :fields)
    end

    def set_custom_field
      @custom_field = CustomField.find(params[:id])
    end

end
