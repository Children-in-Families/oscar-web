class DonorsController < AdminController
	load_and_authorize_resource

  before_action :find_donor, only: [:update, :destroy]

  def index
    @donors   = Donor.includes(:clients, sponsors: :client).order(:name).page(params[:page]).per(20)
    @results  = Donor.count
    @clients  = Client.select(:id, :given_name, :family_name, :local_given_name, :local_family_name)
  end

  def create
    @donor = Donor.new(donor_params)
    if @donor.save
      redirect_to donors_path, notice: t('.successfully_created')
    else
      redirect_to donors_path, alert: t('.failed_create')
    end
  end

  def update
    if @donor.update_attributes(donor_params)
      redirect_to donors_path, notice: t('.successfully_updated')
    else
      redirect_to donors_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @donor.destroy
      redirect_to donors_url, notice: t('.successfully_deleted')
    else
      redirect_to donors_url, alert: t('.failed_delete')
    end
  end

  def version
		page = params[:per_page] || 20
    @donor = Donor.find(params[:donor_id])
    @versions   = @donor.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def donor_params
    params.require(:donor).permit(:name, :description, :code, client_ids: [])
  end

  def find_donor
    @donor = Donor.find(params[:id])
  end
end
