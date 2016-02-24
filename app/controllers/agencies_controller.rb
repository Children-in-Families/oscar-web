class AgenciesController < ApplicationController
  load_and_authorize_resource

  before_action :find_agency, only: [:edit, :update, :destroy]

  def index
    @agencies = Agency.all.paginate(page: params[:page], per_page: 10)
  end

  def new
    @agency = Agency.new
  end

  def create
    @agency = Agency.new(agency_params)
    if @agency.save
      redirect_to agencies_path, notice: 'ឣង្គភាពបង្កើតកំណត់ត្រាថ្មីបានដោយជោគជ័យ / Agency has been successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @agency.update_attributes(agency_params)
      redirect_to agencies_path, notice: 'ឣង្គភាពបានsaveដោយជោគជ័យ / Agency has been successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @agency.clients.present?
      redirect_to agencies_url, alert: 'Agency cannot be deleted.'
    else
      @agency.destroy
      redirect_to agencies_url, notice: 'ឣង្គភាពត្រូវបានលុបចោលដោយជោគជ័យ / Agency has been successfully deleted.'
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
