class ProvincesController < AdminController
  load_and_authorize_resource

  before_action :find_province, only: [:edit, :update, :destroy]

  def index
    @provinces = Province.all.paginate(page: params[:page], per_page: 20)
  end

  def new
    @province = Province.new
  end

  def create
    @province = Province.new(province_params)
    if @province.save
      redirect_to provinces_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @province.update_attributes(province_params)
      redirect_to provinces_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @province.families_count.zero? && @province.partners_count.zero? && @province.users_count.zero? && @province.clients_count.zero? && @province.cases_count.zero?
      @province.destroy
      redirect_to provinces_url, notice: t('.successfully_deleted')
    else
      redirect_to provinces_url, alert: t('.alert')
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
