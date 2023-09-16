class FormBuilder::CustomFieldsController < AdminController
  load_and_authorize_resource

  before_action :set_custom_field, only: [:edit, :update, :destroy, :hidden]
  before_action :remove_html_tags, only: [:create, :update]

  def index
    @custom_fields = CustomField.ordered_by(column_order).page(params[:page_1]).per(20)
    @all_custom_fields = Kaminari.paginate_array(find_custom_field_in_organization).page(params[:page_2]).per(20)
    @demo_custom_fields = Kaminari.paginate_array(find_custom_field_in_organization('demo')).page(params[:page_3]).per(20) unless current_organization.short_name == 'demo'
  end

  def new
    ngo_name = params[:ngo_name]
    original_custom_field = get_custom_field(params[:custom_field_id], ngo_name)
    if ngo_name.present? && original_custom_field
      @custom_field = CustomField.new(original_custom_field.attributes.merge(id: nil))
    else
      @custom_field = CustomField.new
    end
  end

  def show
    ngo_name = params[:ngo_name]
    if ngo_name.present?
      @custom_field = get_custom_field(params[:custom_field_id].to_i, ngo_name)
      redirect_to custom_fields_path, alert: "The organization #{ngo_name} was not found. This error happend only in staging and development not in live." if @custom_field == false
    else
      @custom_field = CustomField.find(params[:id])
    end
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
    ngo_name = params[:ngo_name]
    redirect_to custom_fields_path, alert: t('unauthorized.default') if ngo_name.present? && ngo_name != current_organization.full_name
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
    @custom_fields = Kaminari.paginate_array(search_custom_fields).page(params[:page]).per(20)
    redirect_to custom_fields_path, alert: t('.no_result') if @custom_fields.blank?
  end

  def hidden
    if @custom_field.update({hidden: params[:hidden]})
      redirect_to custom_fields_path, notice: t('form_builder.custom_fields.update.successfully_updated')
    else
      redirect_to custom_fields_path, alert: t('.failed_to_update')
    end
  end

  private

  def get_custom_field(id, ngo_name)
    current_org_name = current_organization.short_name
    ngo = Organization.find_by(full_name: ngo_name)
    return false if ngo.nil?
    ngo_short_name = ngo.short_name
    Organization.switch_to(ngo_short_name)
    original_custom_field = CustomField.find(id)
    Organization.switch_to(current_org_name)
    original_custom_field
  end

  def find_custom_field_in_organization(org = '')
    current_org_name = current_organization.short_name
    organizations = org == 'demo' ? Organization.where(short_name: 'demo') : Organization.oscar.order(:full_name)
    custom_fields = organizations.map do |org|
      Organization.switch_to org.short_name
      CustomField.order(:entity_type, :form_title).reload
    end
    Organization.switch_to(current_org_name)
    sort_custom_fields(custom_fields.flatten, org)
  end

  def sort_custom_fields(custom_fields, org)
    column = params[:order]
    tab = params[:tab]
    default_order = custom_fields.sort_by{ |c| [c.form_title.downcase, c.entity_type] }
    return default_order  unless tab == 'current' || column.present?

    ordered = custom_fields.sort_by{ |c| c.send(column).downcase } if column.present?
    custom_fields_ordered = (column.present? && params[:descending] == 'true' ? ordered.reverse : ordered)

    custom_fields_demo    = tab == 'demo_ngo' && column.present? ? custom_fields_ordered : default_order
    custom_fields_all_ngo = tab == 'all_ngo' && column.present? ? custom_fields_ordered : default_order
    org == 'demo' ? custom_fields_demo : custom_fields_all_ngo
  end

  def column_order
    order_string = 'form_title, entity_type'
    column = params[:order]
    return order_string unless params[:tab] == 'current' || column.present?

    sort_by = params[:descending] == 'true' ? 'desc' : 'asc'
    (order_string = "lower(#{column}) #{sort_by}") if column.present?

    order_string
  end

  def search_custom_fields
    results = []
    if params[:search].present?
      form_title   = params[:search]
      current_org_name = current_organization.short_name
      orgs = current_org_name == 'cwd' ? Organization.all : Organization.without_cwd
      orgs.each do |org|
        Organization.switch_to(org.short_name)
          custom_fields = CustomField.by_form_title(form_title)
          results << custom_fields if custom_fields.present?
      end
      Organization.switch_to(current_org_name)
    end
    results.flatten.sort! {|x, y| x.form_title.downcase <=> y.form_title.downcase}
  end

  def custom_field_params
    params.require(:custom_field).permit(:entity_type, :fields, :form_title, :frequency, :time_of_frequency, :hidden)
  end

  def remove_html_tags
    fields = params[:custom_field][:fields]
    params[:custom_field][:fields] = ActionController::Base.helpers.strip_tags(fields).gsub(/(\\n)|(\\t)/, "")
  end

  def set_custom_field
    @custom_field = CustomField.find(params[:id])
  end

  def find_ngo_name
    @ngo_name = params[:ngo_name]
  end
end
