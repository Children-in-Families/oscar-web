class FormBuilder::CustomFieldsController < AdminController
  before_action :set_custom_field, only: [:show, :edit, :update, :destroy]

  def index
    @custom_fields = CustomField.all
  end

  def new
    @custom_field = CustomField.new
  end

  def create
    @custom_field = CustomField.new(custom_field_params)
    if @custom_field.save
      redirect_to @custom_field, notice: 'Successfully created a custom fields'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to @custom_field, notice: 'Successfully update a custom field'
    else
      render :edit
    end
  end

  def destroy
    if @custom_field.destroy
      redirect_to custom_field_url, notice: 'Successfully deleted a custom field'
    else
      redirect_to custom_field_url, alert: 'Failed to delete a custom field'
    end
  end

  private
    def custom_field_params
      params.require(:custom_field).permit(:entity_name, :fields, :form_type)
    end

    def set_custom_field
      @custom_field = CustomField.find(params[:id])
    end

end
