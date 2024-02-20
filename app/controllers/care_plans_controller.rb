class CarePlansController < AdminController
  include CreateNestedValue
  load_and_authorize_resource

  before_action :set_client, :find_all_assessments
  before_action :find_previou_assessment_and_care_plan, only: [:new, :create, :edit]
  before_action :set_care_plan, :find_assessment, only: [:edit, :update]

  def index
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_readable
    end
    @care_plans = @client.care_plans.page(params[:page])
  end

  def new
    @care_plan = @client.care_plans.new
  end

  def create
    @care_plan = @client.care_plans.new(care_plan_params)
    assessment = Assessment.find(@care_plan.assessment_id)
    if assessment.care_plan.nil? && (current_setting.disable_required_fields? ? @care_plan.save(validate: false) : @care_plan.save)
      redirect_to client_care_plans_path(@client), notice: t('.successfully_created', care_plan: t('clients.care_plan'))
    else
      render :new
    end
  end

  def show
    @care_plan = @client.care_plans.find(params[:id])
  end

  def edit
  end

  def update
    if @care_plan.update_attributes(care_plan_params)
      redirect_to client_care_plans_path(@client), notice: t('.successfully_updated', care_plan: t('clients.care_plan'))
    else
      flash[:alert] = @care_plan.errors.full_messages
      render :edit
    end
  end

  def destroy
    if @care_plan.present?
      @care_plan.goals.each do |goal|
        goal.tasks(&:destroy_fully!)
        goal.reload.destroy
      end
      @care_plan.reload.destroy
      redirect_to client_care_plans_path(@client), notice: t('care_plans.destroy.successfully_deleted', care_plan: t('clients.care_plan'))
    end
  end

  private

  def care_plan_params
    params.require(:care_plan).permit(
      :assessment_id, :client_id, :care_plan_date, :completed,
      goals_attributes: [
        :id, :assessment_domain_id, :assessment_id, :description, :_destroy,
        {
          tasks_attributes: [
            :id, :domain_id, :name, :expected_date, :relation, :user_id, :client_id, :family_id, :previous_id, :goal_id, :_destroy
          ]
        }
      ]
    )
  end

  def care_plan_update_params
    params.require(:care_plan).permit(:assessment_id, :client_id, :completed, goals_attributes: [:id, :assessment_domain_id, :assessment_id, :description, :_destroy, tasks_attributes: [:id, :domain_id, :name, :expected_date, :relation, :_destroy]])
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_all_assessments
    @assessments = @client.assessments.completed.order(:created_at)
  end

  def find_assessment
    @assessment = @care_plan.assessment.decorate
  end

  def set_care_plan
    @care_plan = @client.care_plans.find(params[:id])
  end

  def find_previou_assessment_and_care_plan
    @assessment = @client.assessments.find_by(id: params[:assessment])
    @prev_care_plan = @client.care_plans.last
  end
end
