class FormBuilder::CustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_custom_field, only: [:edit, :update, :destroy, :show]

  def index
    @custom_fields = CustomField.all
  end

  def new
    @custom_field = CustomField.new
  end

  def create
    @custom_field = CustomField.new(custom_field_params)
    if @custom_field.save
      redirect_to custom_fields_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to custom_fields_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @custom_field.destroy
      redirect_to custom_fields_path, notice: t('.successfully_deleted')
    else
      redirect_to custom_fields_path, alert: t('.failed_to_delete')
    end
  end

  private
    def custom_field_params
      params.require(:custom_field).permit(:entity_type, :fields, :form_title)
    end

    def set_custom_field
      @custom_field = CustomField.find(params[:id])
    end

end
