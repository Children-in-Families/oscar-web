class CustomDataController < AdminController
  before_action :find_custom_data, only: %i[edit update]
  before_action :remove_html_tags, only: [:create, :update]

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

  def remove_html_tags
    fields = params.dig(:custom_data, :fields)
    params[:custom_data][:properties] = ActionController::Base.helpers.strip_tags(fields).gsub(/(\\n)|(\\t)|&nbsp;/, '') if fields
  end
end
