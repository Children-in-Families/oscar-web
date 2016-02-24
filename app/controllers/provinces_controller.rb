class ProvincesController < ApplicationController
  load_and_authorize_resource

  before_action :find_province, only: [:edit, :update, :destroy]

  def index
    @provinces = Province.all
  end

  def new
    @province = Province.new
  end

  def create
    @province = Province.new(province_params)
    if @province.save
      redirect_to provinces_path, notice: 'ខេត្ត​បង្កើតបានដោយជោគជ័យ / Province has been successfully created.'
    else
      render :new
    end    
  end

  def edit
  end

  def update
    if @province.update_attributes(province_params)
      redirect_to provinces_path, notice: 'ខេត្ត​saveបានដោយជោគជ័យ / Province has been successfully updated.'
    else
      render :edit
    end    
  end
  
  def destroy
    if @province.families_count.zero? && @province.partners_count.zero? && @province.users_count.zero? && @province.clients_count.zero? && @province.cases_count.zero?
      @province.destroy
      redirect_to provinces_url, notice: 'ខេត្ត​ត្រូវបានលុបចោលដោយជោគជ័យ / Province has been successfully deleted.'
    else
      redirect_to provinces_url, alert: 'Province cannot be deleted.'
    end
  end

  private

  def province_params
    params.require(:province).permit(:name)
  end

  def find_province
    @province = Province.find(params[:id])
  end

end