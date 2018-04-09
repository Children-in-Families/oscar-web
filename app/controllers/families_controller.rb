class FamiliesController < AdminController
  load_and_authorize_resource
  include FamilyAdvancedSearchesConcern

  before_action :find_params_advanced_search, :get_custom_form, only: [:index]
  before_action :get_custom_form_fields, :family_builder_fields, only: [:index]
  before_action :basic_params, if: :has_params?, only: [:index]
  before_action :build_advanced_search, only: [:index]

  before_action :find_association, except: [:index, :destroy, :version]
  before_action :find_family, only: [:show, :edit, :update, :destroy]

  def index
    @default_columns = Setting.first.try(:family_default_columns)
    @family_grid = FamilyGrid.new(params.fetch(:family_grid, {}).merge!(dynamic_columns: @custom_form_fields))
    @family_columns ||= FamilyColumnsVisibility.new(@family_grid, params.merge(column_form_builder: @custom_form_fields))
    @family_columns.visible_columns
    if has_params?
      advanced_search
    else
      respond_to do |f|
        f.html do
          @results = @family_grid.assets.size
          @family_grid.scope { |scope| scope.page(params[:page]).per(20) }
        end
        f.xls do
          form_builder_report
          send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
        end
      end
    end
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    if @family.save
      redirect_to @family, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
    custom_field_ids            = @family.custom_field_properties.pluck(:custom_field_id)
    @free_family_forms          = CustomField.family_forms.not_used_forms(custom_field_ids).order_by_form_title
    @group_family_custom_fields = @family.custom_field_properties.group_by(&:custom_field_id)

    @client_grid = ClientGrid.new(params[:client_grid])
    @results = @client_grid.scope.where(id: @family.children).uniq.size
    @client_grid.scope { |scope| scope.where(id: @family.children).page(params[:page]).per(10).uniq }
  end

  def edit
  end

  def update
    if @family.update_attributes(family_params)
      redirect_to @family, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @family.cases.count.zero?
      @family.destroy
      redirect_to families_url, notice: t('.successfully_deleted')
    else
      redirect_to families_url, alert: t('.alert')
    end
  end

  def version
    page = params[:per_page] || 20
    @family   = Family.find(params[:family_id])
    @versions = @family.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def family_params
    params['family']['children'].delete_if(&:empty?)
    params.require(:family).permit(
                            :name, :code, :case_history, :caregiver_information,
                            :significant_family_member_count, :household_income,
                            :dependable_income, :female_children_count,
                            :male_children_count, :female_adult_count,
                            :male_adult_count, :family_type, :contract_date,
                            :address, :province_id,
                            custom_field_ids: [],
                            children: []
                            )
  end

  def find_association
    @clients  = Client.accessible_by(current_ability).order(:given_name, :family_name)
    @province = Province.order(:name)
  end

  def find_family
    @family = Family.find(params[:id])
  end
end
