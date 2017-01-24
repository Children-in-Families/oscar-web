class FamiliesController < AdminController
  load_and_authorize_resource

  before_action :find_province, except: [:index, :destroy]
  before_action :find_family, only: [:show, :edit, :update, :destroy]
  before_action :set_custom_field, only: [:new, :create, :edit, :update]

  def index
    @family_grid = FamilyGrid.new(params[:family_grid])
    respond_to do |f|
      f.html do
        @results = @family_grid.assets.size
        @family_grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
      f.xls do
        send_data @family_grid.to_xls, filename: "family_report-#{Time.now}.xls"
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
    if @family.cases_count.zero?
      @family.destroy
      redirect_to families_url, notice: t('.successfully_deleted')
    else
      redirect_to families_url, alert: t('.alert')
    end
  end

  def version
    @family   = Family.find(params[:family_id])
    @versions = @family.versions.reorder(created_at: :desc)
  end

  private

  def set_custom_field
    @custom_field = CustomField.find_by(entity_name: 'Family')
  end

  def family_params
    params.require(:family).permit(
                            :name, :caregiver_information,
                            :significant_family_member_count, :household_income,
                            :dependable_income, :female_children_count,
                            :male_children_count, :female_adult_count,
                            :male_adult_count, :family_type, :contract_date,
                            :address, :province_id)
                              .merge(properties: (params['family']['properties']).to_json)
  end

  def find_province
    @province = Province.order(:name)
  end

  def find_family
    @family = Family.find(params[:id])
  end
end
