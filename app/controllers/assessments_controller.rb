class AssessmentsController < AdminController
  include ApplicationHelper
  include CreateBulkTask
  include AssessmentConcern
  include AssessmentHelper

  before_action :find_client, :list_all_case_conferences
  before_action :find_assessment, only: [:edit, :update, :show, :destroy, :upload_attachment]
  before_action :authorize_client, only: [:new, :create, :upload_attachment]
  before_action :authorize_assessment, only: [:show, :edit, :update]
  before_action :fetch_available_custom_domains, only: :index

  def index
    @default_assessment = @client.assessments.new
    @custom_assessment = @client.assessments.new(default: false)
    @assessmets = AssessmentDecorator.decorate_collection(@client.assessments.order(:created_at))
    @custom_assessment_settings = CustomAssessmentSetting.all.where(enable_custom_assessment: true)
  end

  def new
    @from_controller = params[:from]
    @custom_assessment_setting = find_custom_assessment_setting
    custom_assessment_setting_id = @custom_assessment_setting.try(:id)
    @assessment = @client.assessments.new(default: default?, case_conference_id: params[:case_conference], custom_assessment_setting_id: custom_assessment_setting_id)

    authorize(@assessment, :new?, @custom_assessment_setting.try(:id)) if current_organization.try(:aht) == false
    if @custom_assessment_setting.present? && !policy(@assessment).create?(custom_assessment_setting_id)
      redirect_to client_assessments_path(@client), alert: "#{I18n.t('assessments.index.next_review')} of #{@custom_assessment_setting.custom_assessment_name}: #{date_format(@client.custom_next_assessment_date(nil, @custom_assessment_setting.id))}"
    else
      routes_params = params.to_unsafe_h.slice('default', 'custom_name', 'case_conference', 'from_controller')
      redirect_to(edit_client_assessment_path(@client, routes_params.merge(id: :draft)))
    end
  end

  def create
    @assessment = @client.assessments.new(assessment_params)
    @assessment.default = params[:default]
    if current_organization.try(:aht) == true
      case_conference = CaseConference.find(assessment_params[:case_conference_id])
      if case_conference.assessment.nil? && @assessment.save(validate: false)
        if params[:from_controller] == 'dashboards'
          redirect_to root_path, notice: t('.successfully_created')
        else
          redirect_to client_path(@client), notice: t('.successfully_created')
        end
      elsif case_conference.assessment
        params[:assessment][:assessment_domains_attributes].each do |assessment_domain|
          add_more_attachments(assessment_domain.second[:attachments], assessment_domain.second[:id])
        end
        assessment = case_conference.assessment.reload

        assessment_domains_attributes = assessment_params[:assessment_domains_attributes].select { |k, v| v['score'].present? }
        assessment.update(updated_at: DateTime.now)
        assessment.assessment_domains.update_all(assessment_id: assessment.id)
        assessment_domains_attributes.each do |_, v|
          attr = v.slice('domain_id', 'score')
          assessment.assessment_domains.reload.find_by(domain_id: attr['domain_id']).update_attributes(attr)
        end

        redirect_to client_assessment_path(@client, assessment), notice: t('.successfully_updated')
      else
        render :new
      end
    else
      css = find_custom_assessment_setting
      authorize @assessment, :create?, css.try(:id)
      if @assessment.save
        if params[:from_controller] == 'dashboards'
          redirect_to root_path, notice: t('.successfully_created')
        else
          redirect_to client_assessment_path(@client, @assessment), notice: t('.successfully_created')
        end
      else
        flash[:alert] = @assessment.errors.full_messages
        render :new, custom_name: css.custom_assessment_name if css
      end
    end
  end

  def show
  end

  def edit
    @prev_assessment = @client.assessments.last
  end

  def update
    attributes = assessment_params.merge(last_auto_save_at: DateTime.now)
    saved = false
    if save_draft?
      @assessment.assign_attributes(attributes)
      PaperTrail.without_tracking { @assessment.save(validate: false) }

      saved = true
    else
      saved = @assessment.update_attributes(attributes.merge(draft: false))
      @assessment.run_callbacks(:commit)
    end

    if saved
      create_bulk_task(params[:task], @assessment) if params.has_key?(:task)

      respond_to do |format|
        format.html { redirect_to client_assessment_path(@client, @assessment), notice: t('.successfully_updated') }
        format.json { render json: { resource: @assessment, edit_url: edit_client_assessment_path(@client, @assessment) }, status: '200' }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @assessment.errors, status: 422 }
      end
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
      if @assessment.destroy
        redirect_to client_assessments_path(@assessment.client), notice: t('.successfully_deleted_assessment')
      else
        messages = @assessment.errors.full_messages.uniq.join('\n')
        redirect_to [@client, @assessment], alert: messages
      end
    end
  end

  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_assessment
    @assessment = Assessment.unscoped do
      if params[:id] == 'draft'
        @custom_assessment_setting = find_custom_assessment_setting
        @client.find_or_create_assessment(default: default?, case_conference_id: params[:case_conference], custom_assessment_setting_id: @custom_assessment_setting.try(:id))
      else
        @client.assessments.find(params[:id])
      end
    end.decorate
  end

  def authorize_client
    authorize @client, :create?
  end

  def authorize_assessment
    authorize @assessment
  end

  def assessment_params
    default_params = params.require(:assessment).permit(:default, :assessment_date, :case_conference_id, :custom_assessment_setting_id, :level_of_risk, :description, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last])
    default_params = params.require(:assessment).permit(:default, :assessment_date, :case_conference_id, :custom_assessment_setting_id, :level_of_risk, :description, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last, attachments: []]) if action_name == 'create'
    default_params
  end

  def remove_attachment_at_index(index)
    assessment_domain = AssessmentDomain.find(params[:assessment_domain])
    remain_attachment = assessment_domain.attachments
    deleted_attachment = remain_attachment.delete_at(index)
    deleted_attachment.try(:remove_images!)
    remain_attachment.try(:empty?) ? assessment_domain.remove_attachments! : (assessment_domain.attachments = remain_attachment)
    message = t('.fail_delete_attachment') unless assessment_domain.save
  end

  def default?
    params[:default] == 'true'
  end

  def fetch_available_custom_domains
    @custom_domains = Domain.custom_csi_domains
  end

  def list_all_case_conferences
    @case_conferences = @client.case_conferences if Organization.ratanak?
  end
end
