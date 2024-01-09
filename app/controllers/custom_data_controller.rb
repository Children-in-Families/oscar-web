class CustomDataController < AdminController
  before_action :find_custom_data, only: %i[edit update]
  def index
    @custom_data = CustomData.first
  end

  def new
    redirect_to custom_data_path if CustomData.first&.persisted?

    @custom_data = CustomData.new
  end

  def create
    @custom_data = CustomData.new(custom_data_params)
    if @custom_data.save
      redirect_to custom_data_path, notice: t('successfully_created', klass: 'Custom Data')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @custom_data.update_attributes(custom_data_params)
      redirect_to custom_data_path, notice: t('successfully_updated', klass: 'Custom Data')
    else
      render :edit
    end
  end

  private

  def custom_data_params
    params.require(:custom_data).permit(:fields)
  end

  def find_custom_data
    @custom_data = CustomData.find(params[:id])
  end
end
