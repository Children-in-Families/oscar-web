class DistrictsController < AdminController
  load_and_authorize_resource

  before_action :find_district, only: [:update, :destroy]

  def index
    @provinces = Province.order(:name)
    @districts = District.joins(:province).order('provinces.name').order(:name).page(params[:page]).per(20)
    @results   = District.count
  end

  def create
    @district = District.new(district_params)
    if @district.save
      redirect_to districts_path, notice: t('.successfully_created')
    else
      redirect_to districts_path, alert: t('.failed_create')
    end
  end

  def update
    if @district.update_attributes(district_params)
      redirect_to districts_path, notice: t('.successfully_updated')
    else
      redirect_to districts_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @district.clients.count.zero?
      @district.destroy
      redirect_to districts_path, notice: t('.successfully_deleted')
    else
      redirect_to districts_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @district = District.find(params[:district_id])
    @versions = @district.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def district_params
    params.require(:district).permit(:name, :province_id)
  end

  def find_district
    @district = District.find(params[:id])
  end
end
