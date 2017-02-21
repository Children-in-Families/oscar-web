class InterventionsController < AdminController
  load_and_authorize_resource

  before_action :find_intervention, only: [:edit, :update, :destroy]

  def index
    @interventions = Intervention.order(:action).page(params[:page]).per(20)
    @results       = Intervention.count
  end

  def create
    @intervention = Intervention.new(intervention_params)
    if @intervention.save
      redirect_to interventions_path, notice: t('.successfully_created')
    else
      redirect_to interventions_path, alert: t('.failed_create')
    end
  end

  def update
    if @intervention.update_attributes(intervention_params)
      redirect_to interventions_path, notice: t('.successfully_updated')
    else
      redirect_to interventions_path, alert: t('.failed_update')
    end
  end

  def destroy
    if @intervention.destroy
      redirect_to interventions_url, notice: t('.successfully_deleted')
    else
      redirect_to interventions_path, alert: t('.failed_delete')
    end
  end

  def version
    page = params[:per_page] || 20
    @intervention = Intervention.find(params[:intervention_id])
    @versions     = @intervention.versions.reorder(created_at: :desc).page(params[:page]).per(page)
  end

  private

  def intervention_params
    params.require(:intervention).permit(:action)
  end

  def find_intervention
    @intervention = Intervention.find(params[:id])
  end
end
