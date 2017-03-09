class LocationsController < AdminController
  load_and_authorize_resource

  before_action :find_location, only: [:update, :destroy]

  def index
    @locations = Location.order('order_option, name').page(params[:page]).per(20)
    @results   = Location.count
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      redirect_to locations_path, notice: t('.successfully_created')
    else
      redirect_to locations_path, alert: t('.failed_create')
    end
  end

  def update
    if @location.update_attributes(location_params)
      redirect_to locations_path, notice: t('.successfully_updated')
    else
      redirect_to locations_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @location.destroy
      redirect_to locations_url, notice: t('.successfully_deleted')
    else
      redirect_to locations_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @location = Location.find(params[:location_id])
    @versions = @location.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def find_location
    @location = Location.find(params[:id])
  end
end
