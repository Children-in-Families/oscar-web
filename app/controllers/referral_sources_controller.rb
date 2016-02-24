class ReferralSourcesController < ApplicationController

  load_and_authorize_resource

  before_action :find_referral_source, only: [:edit, :update, :destroy]  

  def index
    @referral_sources = ReferralSource.all.paginate(page: params[:page], per_page: 10)
  end

  def new
    @referral_source = ReferralSource.new
  end

  def create
    @referral_source = ReferralSource.new(referral_source_params)
    if @referral_source.save
      redirect_to referral_sources_path, notice: 'ប្រភព​នៃ​ការបញ្ជូន​បង្កើតបានដោយជោគជ័យ / Referral Source has been successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @referral_source.update_attributes(referral_source_params)
      redirect_to referral_sources_path, notice: 'ប្រភព​នៃ​ការបញ្ជូន​saveបានដោយជោគជ័យ / Referral Source has been successfully updated.'
    else
      render :edit
    end    
  end
  
  def destroy
    if @referral_source.clients_count.zero?
      @referral_source.destroy
      redirect_to referral_sources_url, notice: 'ប្រភព​នៃ​ការបញ្ជូន​ត្រូវបានលុបចោលដោយជោគជ័យ / Referral Source has been successfully deleted.'
    else
      redirect_to referral_sources_url, alert: 'Referral Source cannot be deleted.'
    end
  end

  private

  def referral_source_params
    params.require(:referral_source).permit(:name, :description)
  end

  def find_referral_source
    @referral_source = ReferralSource.find(params[:id])
  end
  
end
