class ProvincesController < AdminController
  load_and_authorize_resource

  before_action :find_province, only: [:update, :destroy]

  def index
    @provinces = Province.order(:name).page(params[:page]).per(20)
    @results   = Province.count
  end

  def create
    @province = Province.new(province_params)
    if @province.save
      redirect_to provinces_path, notice: t('.successfully_created')
    else
      redirect_to provinces_path, alert: t('.failed_create')
    end
  end

  def update
    if @province.update_attributes(province_params)
      redirect_to provinces_path, notice: t('.successfully_updated')
    else
      redirect_to provinces_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @province.families.count.zero? && @province.partners.count.zero? && @province.users.count.zero? && @province.clients.count.zero? && @province.cases.count.zero?
      @province.destroy
      redirect_to provinces_url, notice: t('.successfully_deleted')
    else
      redirect_to provinces_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @province = Province.find(params[:province_id])
    @versions = @province.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def province_params
    params.require(:province).permit(:name)
  end

  def find_province
    @province = Province.find(params[:id])
  end
end
