class AgenciesController < AdminController
  load_and_authorize_resource

  before_action :find_agency, only: [:edit, :update, :destroy]

  def index
    @agencies = Agency.all.paginate(page: params[:page], per_page: 20)
  end

  def new
    @agency = Agency.new
  end

  def create
    @agency = Agency.new(agency_params)
    if @agency.save
      redirect_to agencies_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @agency.update_attributes(agency_params)
      redirect_to agencies_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @agency.clients.present?
      redirect_to agencies_url, alert: t('.alert')
    else
      @agency.destroy
      redirect_to agencies_url, notice: t('.successfully_deleted')
    end
  end

  private

  def agency_params
    params.require(:agency).permit(:name, :description)
  end

  def find_agency
    @agency = Agency.find(params[:id])
  end
end
