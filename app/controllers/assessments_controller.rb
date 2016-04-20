class AssessmentsController < AdminController
  load_and_authorize_resource

  before_action :find_client
  before_action :find_assessment, only: [:edit, :update, :show]
  before_action :restrict_invalid_assessment, only: [:new, :create]
  before_action :restrict_update_assessment, only: [:edit, :update]

  def index
  end

  def new
    @assessment = @client.assessments.new
    @assessment.populate_notes
  end

  def create
    @assessment = @client.assessments.new(assessment_params)
    if @assessment.save
      if @assessment.assessment_domains.any_problems?
        redirect_to new_client_task_path(assessment_id: @assessment.id)
      else
        redirect_to client_assessment_path(@client, @assessment), notice: t('.successfully_created')
      end
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @assessment.update_attributes(assessment_params)
      redirect_to client_assessment_path(@client, @assessment), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).find(params[:client_id])
  end

  def find_assessment
    @assessment = @client.assessments.find(params[:id])
  end

  def assessment_params
    params.require(:assessment).permit(assessment_domains_attributes: [:id, :domain_id, :score, :reason])
  end

  def restrict_invalid_assessment
    redirect_to client_assessments_path(@client) unless @client.can_create_assessment?
  end

  def restrict_update_assessment
    redirect_to client_assessments_path(@client) unless @assessment.latest_record?
  end

end
