class CarePlansController < AdminController
  include CreateNestedValue
  load_and_authorize_resource

  before_action :set_client, :get_all_assessments
  before_action :set_care_plan, :find_assessment, only: [:edit, :update]

  def index
    unless current_user.admin? || current_user.strategic_overviewer?
      redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.case_notes_readable
    end
    @care_plans = @client.care_plans.page(params[:page])
  end

  def new
    @assessment = @client.assessments.find_by(id: params[:assessment])
    @prev_care_plan = @client.care_plans.last
    @care_plan = Setting.first.try(:use_previous_care_plan) && @prev_care_plan || @client.care_plans.new()
  end

  def create
    @care_plan = @client.care_plans.new(care_plan_params)
    if @care_plan.save(validate: false)
      params[:care_plan][:goals_attributes].each do |goal|
        create_nested_value(goal)
      end
      redirect_to client_care_plans_path(@client), notice: t('.successfully_created', care_plan: t('clients.care_plan'))
    else
      render :new
    end
  end

  def show
    @care_plan = @client.care_plans.find(params[:id])
  end

  def edit
    # unless current_user.admin? || current_user.strategic_overviewer?
    #   redirect_to root_path, alert: t('unauthorized.default') unless current_user.permission.care_plans_editable
    # end
  end

  def update
    if @care_plan.update_attributes(care_plan_params) && @care_plan.save
      care_plan_update_params[:goals_attributes].each do |goal|
        update_nested_value(goal)
      end
      redirect_to client_care_plans_path(@client), notice: t('.successfully_updated', care_plan: t('clients.care_plan'))
    else
      render :edit
    end
  end

  def destroy
    if @care_plan.present?
      @care_plan.goals.each do |goal|
        goal.tasks.each do |task|
          task.destroy_fully!
        end
        goal.reload.destroy
      end
      @care_plan.reload.destroy
      redirect_to client_care_plans_path(@client), notice: t('care_plans.destroy.successfully_deleted', care_plan: t('clients.care_plan'))
    end
  end

  private

  def care_plan_params
    params.require(:care_plan).permit(:assessment_id, :client_id, :completed)
  end

  def care_plan_update_params
    params.require(:care_plan).permit(:assessment_id, :client_id, :completed, goals_attributes: [:id, :assessment_domain_id, :assessment_id, :description, :_destroy, tasks_attributes: [:id, :domain_id, :name, :expected_date, :relation, :_destroy]])
  end

  def set_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def get_all_assessments
    @assessments = @client.assessments.completed
  end

  def find_assessment
    @assessment = @care_plan.assessment.decorate
  end

  def set_care_plan
    @care_plan = @client.care_plans.find(params[:id])
  end


end
