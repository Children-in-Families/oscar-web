class LocationsController < AdminController
  load_and_authorize_resource

  before_action :find_location, only: [:edit, :update, :destroy]

  def index
    @locations = Location.order('order_option, name').paginate(page: params[:page], per_page: 20)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      redirect_to locations_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @location.update_attributes(location_params)
      redirect_to locations_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @location.destroy
      redirect_to locations_url, notice: t('.successfully_deleted')
    else
      redirect_to locations_url, notice: t('.unsuccessfully_deleted')
    end
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end

  def find_location
    @location = Location.find(params[:id])
  end
end
