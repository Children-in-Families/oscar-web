class ServiceDeliveriesController < AdminController
  before_action :find_service_delivery, except: :index
  before_action :find_sub_category, except: [:index, :destroy]

  def index
    @main_services = ServiceDelivery.only_parents
    @service_deliveries = ServiceDelivery.only_children
  end

  def new
    @service_delivery = ServiceDelivery.new
  end

  def create
    @service_delivery = ServiceDelivery.new(service_delivery_params)
    if @service_delivery.save
      redirect_to service_deliveries_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @service_delivery.update_attributes(service_delivery_params)
      redirect_to service_deliveries_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @service_delivery.destroy
      redirect_to service_deliveries_path, notice: t('.successfully_deleted')
    else
      messages = @service_delivery.errors.full_messages.uniq.join('\n')
      redirect_to service_deliveries_path, alert: messages
    end
  end

  private

  def service_delivery_params
    params.require(:service_delivery).permit(:name, :parent_id)
  end

  def find_service_delivery
    @service_delivery = ServiceDelivery.find(params[:id]) if params[:id]
  end

  def find_sub_category
    @sub_categories = ServiceDelivery.where(parent_id: params['parent_id']) if params['parent_id']
  end
end
