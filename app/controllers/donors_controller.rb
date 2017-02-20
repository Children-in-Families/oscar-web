class DonorsController < ApplicationController
	load_and_authorize_resource

  before_action :find_donor, only: [:update, :destroy]

  def index
    @donors = Donor.order(:name).page(params[:page]).per(20)
    @results     = Donor.count
  end

  def create
    @donor = Donor.new(donor_params)
    if @donor.save
      redirect_to donor_path, notice: t('.successfully_created')
    else
      redirect_to donor_path, alert: t('.failed_create')
    end
  end

  def update
    if @donor.update_attributes(donor_params)
      redirect_to donor_path, notice: t('.successfully_updated')
    else
      redirect_to donor_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @donor.users_count.zero?
      @donor.destroy
      redirect_to donors_url, notice: t('.successfully_deleted')
    else
      redirect_to donors_url, alert: t('.failed_delete')
    end
  end

  def version
    @donor = Donor.find(params[:donor_id])
    @versions   = @donor.versions.reorder(created_at: :desc)
  end

  private

  def donor_params
    params.require(:donor).permit(:name, :description)
  end

  def find_donor
    @donor = Donor.find(params[:id])
  end
end
