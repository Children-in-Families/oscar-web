class QuantitativeTypesController < AdminController
  load_and_authorize_resource

  before_action :find_quantitative_type, only: [:update, :destroy]

  def index
    @quantitative_types = QuantitativeType.all.page(params[:page]).per(10)
    @results            = QuantitativeType.count
  end

  def create
    @quantitative_type = QuantitativeType.new(quantitative_type_params)
    if @quantitative_type.save
      redirect_to quantitative_types_path, notice: t('.successfully_created')
    else
      redirect_to quantitative_types_path, alert: t('.failed_create')
    end
  end

  def update
    if @quantitative_type.update_attributes(quantitative_type_params)
      redirect_to quantitative_types_path, notice: t('.successfully_updated')
    else
      redirect_to quantitative_types_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @quantitative_type.quantitative_cases.count.zero?
      @quantitative_type.destroy
      redirect_to quantitative_types_path, notice: t('.successfully_deleted')
    else
      redirect_to quantitative_types_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @quantitative_type = QuantitativeType.find(params[:quantitative_type_id])
    @versions          = @quantitative_type.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def quantitative_type_params
    params.require(:quantitative_type)
          .permit(:name, :description, quantitative_cases_attributes: [:id, :value, :_destroy])
  end

  def find_quantitative_type
    @quantitative_type = QuantitativeType.find(params[:id])
  end
end
