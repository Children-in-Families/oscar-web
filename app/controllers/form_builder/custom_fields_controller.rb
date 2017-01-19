class FormBuilder::CustomFieldsController < AdminController
  before_action :set_custom_field, only: [:show, :edit, :update]

  def index
    @custom_fields = CustomField.all
  end

  def new
    @custom_field = CustomField.new
  end

  def create
    @custom_field = CustomField.new(custom_field_params)
    if @custom_field.save
      redirect_to custom_fields_url
    else
      render :new
    end
  end

  def show
  end

  private
    def custom_field_params
      params.require(:custom_field).permit(:entity_name, :fields)
    end

    def set_custom_field
      @custom_field = CustomField.find(params[:id])
    end

end
