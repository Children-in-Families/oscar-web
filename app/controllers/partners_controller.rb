class PartnersController < AdminController
  load_and_authorize_resource

  include PartnerAdvancedSearchesConcern

  before_action :find_params_advanced_search, :get_custom_form, only: [:index]
  before_action :get_custom_form_fields, :partner_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]
  before_action :find_partner, only: [:show, :edit, :update, :destroy]
  before_action :find_association, except: [:index, :destroy, :version]

  def index
    @default_columns = Setting.first.try(:partner_default_columns)
    @partner_grid = PartnerGrid.new(params.fetch(:partner_grid, {}).merge!(dynamic_columns: @custom_form_fields))
    @partner_columns ||= PartnerColumnsVisibility.new(@partner_grid, params.merge(column_form_builder: @custom_form_fields))
    @partner_columns.visible_columns
    if has_params?
      advanced_search
    else
      respond_to do |f|
        f.html do
          @results = @partner_grid.assets.size
          @partner_grid.scope { |scope| scope.page(params[:page]).per(20) }
        end
        f.xls do
          send_data @partner_grid.to_xls, filename: "partner_report-#{Time.now}.xls"
        end
      end
    end
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)
    if @partner.save
      redirect_to @partner, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    custom_field_ids = @partner.custom_field_properties.pluck(:custom_field_id)
    @free_partner_forms = CustomField.partner_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_partner_custom_fields = @partner.custom_field_properties.group_by(&:custom_field_id)
  end

  def edit
  end

  def update
    if @partner.update_attributes(partner_params)
      redirect_to @partner, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @partner.cases_count.zero?
      @partner.destroy
      redirect_to partners_url, notice: t('.successfully_deleted')
    else
      redirect_to partners_url, alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @partner = Partner.find(params[:partner_id])
    @versions = @partner.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def partner_params
    params.require(:partner).permit(:name, :contact_person_name, :engagement,
                                    :contact_person_email, :contact_person_mobile, :affiliation,
                                    :background, :start_date, :address, :organization_type_id,
                                    :province_id, custom_field_ids: [])
  end

  def find_partner
    @partner = Partner.find(params[:id])
  end

  def find_association
    @province = Province.order(:name)
    @organization_types = OrganizationType.order(:name)
  end
end
