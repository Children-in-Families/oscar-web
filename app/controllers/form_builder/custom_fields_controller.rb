class FormBuilder::CustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_custom_field, only: [:edit, :update, :destroy, :show]
  before_action :find_ngo_name

  def index
    @custom_fields = CustomField.order(:entity_type, :form_title).page(params[:page_1]).per(20)
    @all_custom_fields = Kaminari.paginate_array(find_custom_field_in_organization).page(params[:page_2]).per(20)
  end

  def new
    if @ngo_name.present?
      original_custom_field = get_custom_field(params[:custom_field_id], @ngo_name)
      @custom_field = CustomField.new(original_custom_field.attributes.merge(id: nil))
    else
      @custom_field = CustomField.new
    end
  end

  def show
    @custom_field = get_custom_field(params[:id], @ngo_name) if @ngo_name.present? && @ngo_name != current_organization.full_name
  end

  def create
    @custom_field = CustomField.new(custom_field_params)
    if @custom_field.save
      redirect_to custom_field_path(@custom_field), notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
    redirect_to custom_fields_path, alert: t('unauthorized.default') if @ngo_name.present? && @ngo_name != current_organization.full_name
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to custom_field_path(@custom_field), notice: t('.successfully_updated')
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

  def search
    if params[:search].present?
      custom_field = find_custom_field(params[:search])
      @custom_fields = Kaminari.paginate_array(custom_field).page(params[:page]).per(20)
      redirect_to custom_fields_path, alert: t('.no_result') if @custom_fields.blank?
    end
  end

  private

  def get_custom_field(id, ngo_name)
    current_org_name = current_organization.short_name
    ngo_short_name = Organization.find_by(full_name: ngo_name).short_name
    Organization.switch_to(ngo_short_name)
    original_custom_field = CustomField.find(id)
    Organization.switch_to(current_org_name)
    original_custom_field
  end

  def find_custom_field_in_organization
    current_org_name = current_organization.short_name
    custom_fields = []
    Organization.without_demo.each do |org|
      Organization.switch_to org.short_name
      custom_fields << CustomField.order(:entity_type, :form_title).reload
    end
    Organization.switch_to(current_org_name)
    custom_fields.flatten
  end

  def find_custom_field(search)
    results = []
    current_org_name = current_organization.short_name
    Organization.without_demo.each do |org|
      Organization.switch_to(org.short_name)
      if params[:search].present?
        form_title   = params[:search]
        custom_fields = CustomField.by_form_title(form_title)
        results << custom_fields if custom_fields.present?
      end
    end
    Organization.switch_to(current_org_name)
    results.flatten
  end

  def custom_field_params
    params.require(:custom_field).permit(:entity_type, :fields, :form_title, :frequency, :time_of_frequency)
  end

  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  end

  def find_ngo_name
    @ngo_name = params[:ngo_name]
  end
end
