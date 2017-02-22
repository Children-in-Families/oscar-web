class AgenciesController < AdminController
  load_and_authorize_resource

  before_action :find_agency, only: [:update, :destroy]

  def index
    @agencies = Agency.order(:name).page(params[:page]).per(20)
    @results  = Agency.count
  end

  def create
    @agency = Agency.new(agency_params)
    if @agency.save
      redirect_to agencies_path, notice: t('.successfully_created')
    else
      redirect_to agencies_path, alert: t('.failed_create')
    end
  end

  def update
    if @agency.update_attributes(agency_params)
      redirect_to agencies_path, notice: t('.successfully_updated')
    else
      redirect_to agencies_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @agency.clients.present?
      redirect_to agencies_url, alert: t('.failed_delete')
    else
      @agency.destroy
      redirect_to agencies_url, notice: t('.successfully_deleted')
    end
  end

  def version
    page = params[:per_page] || 20
    @agency   = Agency.find(params[:agency_id])
    @versions = @agency.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def agency_params
    params.require(:agency).permit(:name, :description)
  end

  def find_agency
    @agency = Agency.find(params[:id])
  end
end
