class FamiliesController < AdminController
  load_and_authorize_resource

  before_action :find_province, except: [:index, :destroy]
  before_action :find_family, only: [:show, :edit, :update, :destroy]

  def index
    @family_grid = FamilyGrid.new(params[:family_grid])
    respond_to do |f|
      f.html do
        @family_grid.scope { |scope| scope.paginate(page: params[:page], per_page: 10) }
      end
      f.csv do
        send_data @family_grid.to_csv, type: 'text/csv',
                                       disposition: 'inline',
                                       filename: "family_report-#{Time.now}.csv"
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
    @versions = @family.versions.reorder(created_at: :desc).decorate
  end

  private

  def family_params
    params.require(:family).permit(:name, :caregiver_information, :significant_family_member_count, :household_income, :dependable_income, :female_children_count, :male_children_count, :female_adult_count, :male_adult_count, :family_type, :contract_date, :address, :province_id)
  end

  def find_province
    @province = Province.order(:name)
  end

  def find_family
    @family = Family.find(params[:id])
  end
end
