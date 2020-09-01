class AssessmentsController < AdminController
  include ApplicationHelper
  include CreateBulkTask

  before_action :find_client
  before_action :find_assessment, only: [:edit, :update, :show, :destroy]
  before_action :authorize_client, only: [:new, :create]
  before_action :authorize_assessment, only: [:show, :edit, :update]
  before_action :fetch_available_custom_domains, only: :index

  def index
    @default_assessment = @client.assessments.new
    @custom_assessment  = @client.assessments.new(default: false)
    @assessmets = AssessmentDecorator.decorate_collection(@client.assessments.order(:created_at))
    @custom_assessment_settings = CustomAssessmentSetting.all.where(enable_custom_assessment: true)
  end

  def new
    @from_controller = params[:from]
    @prev_assessment = @client.assessments.last
    @assessment = @client.assessments.new(default: default?)

    css = CustomAssessmentSetting.find_by(custom_assessment_name: params[:custom_name])
    if current_organization.try(:aht) == false
      authorize @assessment
    end
    if css.present? && !policy(@assessment).create?(css)
      redirect_to client_assessments_path(@client), alert: "#{I18n.t('assessments.index.next_review')} of #{css.custom_assessment_name}: #{date_format(@client.custom_next_assessment_date(nil, css.id))}"
    else
      @assessment.populate_notes(params[:default], params[:custom_name])
    end
  end

  def create
    @assessment = @client.assessments.new(assessment_params)
    @assessment.default = params[:default]
    if current_organization.try(:aht) == true
      if @assessment.save(validate: false)
        create_bulk_task(params[:task].uniq, @assessment) if params.has_key?(:task)
        if params[:from_controller] == "dashboards"
          redirect_to root_path, notice: t('.successfully_created')
        else
          redirect_to client_path(@client), notice: t('.successfully_created')
        end
      else
        render :new
      end
    else
      authorize @assessment
      if @assessment.save
        create_bulk_task(params[:task].uniq, @assessment) if params.has_key?(:task)
        if params[:from_controller] == "dashboards"
          redirect_to root_path, notice: t('.successfully_created')
        else
          redirect_to client_path(@client), notice: t('.successfully_created')
        end
      else
        render :new
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    params[:assessment][:assessment_domains_attributes].each do |assessment_domain|
      add_more_attachments(assessment_domain.second[:attachments], assessment_domain.second[:id])
    end
    if @assessment.update_attributes(assessment_params)
      @assessment.update(updated_at: DateTime.now)
      @assessment.assessment_domains.update_all(assessment_id: @assessment.id)
      create_bulk_task(params[:task], @assessment) if params.has_key?(:task)
      redirect_to client_assessment_path(@client, @assessment), notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if params[:file_index].present?
      remove_attachment_at_index(params[:file_index].to_i)
      message ||= t('.successfully_deleted')
      respond_to do |f|
        f.json { render json: { message: message }, status: '200' }
      end
    elsif @assessment.present?
      @assessment.assessment_domains.delete_all
      @assessment.reload.destroy
      redirect_to client_assessments_path(@assessment.client), notice: t('.successfully_deleted_assessment')
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_assessment
    @assessment = @client.assessments.find(params[:id]).decorate
  end

  def authorize_client
    authorize @client, :create?
  end

  def authorize_assessment
    authorize @assessment
  end

  def assessment_params
    default_params = params.require(:assessment).permit(:default, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last])
    default_params = params.require(:assessment).permit(:default, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last, attachments: []]) if action_name == 'create'
    default_params
  end

  def remove_attachment_at_index(index)
    assessment_domain = AssessmentDomain.find(params[:assessment_domain])
    remain_attachment = assessment_domain.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove_images!)
    remain_attachment.empty? ? assessment_domain.remove_attachments! : (assessment_domain.attachments = remain_attachment )
    message = t('.fail_delete_attachment') unless assessment_domain.save
  end

  def add_more_attachments(new_file, assessment_domain_id)
    if new_file.present?
      assessment_domain = AssessmentDomain.find(assessment_domain_id)
      files = assessment_domain.attachments
      files += new_file
      assessment_domain.attachments = files
      assessment_domain.save
    end
  end

  def default?
    params[:default] == 'true'
  end

  def fetch_available_custom_domains
    @custom_domains = Domain.custom_csi_domains
  end
end
