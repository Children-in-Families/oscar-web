class FormBuilder::CustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_custom_field, only: [:edit, :update, :destroy]

  def index
    @custom_fields = CustomField.order(:entity_type, :form_title)
    @all_custom_fields = find_custom_field_in_organization
  end

  def new
    if params[:ngo_name].present?
      ngo_name = params[:ngo_name]
      current_org_name = current_organiation.short_name
      if ngo_name == current_organiation.full_name
        @custom_fields = CustomField.find(params[:custom_field_id])
      else
        ngo_short_name = Organization.find_by(full_name: ngo_name).short_name
        Organization.switch_to(ngo_short_name)
        @custom_fields = CustomField.find(params[:custom_field_id])
        Organization.switch_to(current_org_name)
      end
      @custom_field = CustomField.new(form_title: @custom_fields.form_title, entity_type: @custom_fields.entity_type, fields: @custom_fields.fields, frequency: @custom_fields.frequency, time_of_frequency: @custom_fields.time_of_frequency)
    else
      @custom_field = CustomField.new
    end
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

  def show
    ngo_name = params[:ngo_name]
    current_org_name = current_organiation.short_name
    if ngo_name == current_organiation.full_name
      @custom_field = CustomField.find(params[:id])
    else
      ngo_short_name = Organization.find_by(full_name: ngo_name).short_name
      Organization.switch_to(ngo_short_name)
      @custom_field = CustomField.find(params[:id])
      Organization.switch_to(current_org_name)
    end
  end

  def search
    if params[:search].present?
      @custom_field = find_custom_field(params[:search])
      if @custom_field.blank?
        redirect_to custom_fields_path, alert: 'dont have this custom field'
      end
    end
  end

  def find
    render json: find_custom_field_in_organization
  end

  private

  def find_custom_field_in_organization
    current_org_name = current_organiation.short_name
    custom_fields = []
    Organization.without_demo.each do |org|
      Organization.switch_to(org.short_name)
      CustomField.find_each do |custom_field|
        custom_fields << custom_field
      end
    end
    Organization.switch_to(current_org_name)
    custom_fields
  end

  def find_custom_field(search)
    found = []
    current_org_name = current_organiation.short_name
    Organization.without_demo.each do |org|
      Organization.switch_to(org.short_name)
      params_custom_field = params[:search] if params[:search].present?
      found_custom_field = CustomField.find_by(form_title: params_custom_field)
      found << found_custom_field if found_custom_field.present?
    end
    Organization.switch_to(current_org_name)
    found.flatten
  end

  def custom_field_params
    params.require(:custom_field).permit(:entity_type, :fields, :form_title, :frequency, :time_of_frequency)
  end

  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  end
end
