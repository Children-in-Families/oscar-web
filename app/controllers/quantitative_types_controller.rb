class QuantitativeTypesController < AdminController
  load_and_authorize_resource

  before_action :find_quantitative_type, only: [:edit, :update, :destroy]

  def index
    @quantitative_types = QuantitativeType.all.paginate(page: params[:page], per_page: 10)
  end

  def new
    @quantitative_type = QuantitativeType.new
  end

  def create
    @quantitative_type = QuantitativeType.new(quantitative_type_params)
    if @quantitative_type.save
      redirect_to quantitative_types_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @quantitative_type.update_attributes(quantitative_type_params)
      redirect_to quantitative_types_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @quantitative_type.quantitative_cases_count.zero?
      @quantitative_type.destroy
      redirect_to quantitative_types_path, notice: t('.successfully_deleted')
    else
      redirect_to quantitative_types_url, alert: t('.alert')
    end
  end

  def version
    @quantitative_type = QuantitativeType.find(params[:quantitative_type_id])
    @versions          = @quantitative_type.versions.reorder(created_at: :desc).decorate
  end

  private

  def quantitative_type_params
    params.require(:quantitative_type).permit(:name, :description)
  end

  def find_quantitative_type
    @quantitative_type = QuantitativeType.find(params[:id])
  end
end
