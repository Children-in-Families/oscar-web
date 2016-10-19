class InterventionsController < AdminController
  load_and_authorize_resource

  before_action :find_intervention, only: [:edit, :update, :destroy]

  def index
    @interventions = Intervention.order(:action).paginate(page: params[:page], per_page: 20)
  end

  def new
    @intervention = Intervention.new
  end

  def create
    @intervention = Intervention.new(intervention_params)
    if @intervention.save
      redirect_to interventions_path, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @intervention.update_attributes(intervention_params)
      redirect_to interventions_path, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @intervention.destroy
      redirect_to interventions_url, notice: t('.successfully_deleted')
    else
      redirect_to interventions_url, notice: t('.unsuccessfully_deleted')
    end
  end

  private

  def intervention_params
    params.require(:intervention).permit(:action)
  end

  def find_intervention
    @intervention = Intervention.find(params[:id])
  end
end
