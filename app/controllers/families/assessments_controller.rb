module Families
  class AssessmentsController < ::AdminController
    include ApplicationHelper
    include AssessmentConcern
    include AssessmentHelper

    before_action :find_family
    before_action :find_assessment, only: [:edit, :update, :show, :destroy]
    before_action :find_custom_assessment_setting, :authorize_client, only: [:new, :create]
    before_action :fetch_available_custom_domains, only: :index

    def index
      @custom_assessment  = @family.assessments.new(default: false)
      @custom_assessment_settings = []
      @assessmets = AssessmentDecorator.decorate_collection(@family.assessments.order(:created_at))
    end

    def new
      @from_controller = params[:from]
      @prev_assessment = @family.assessments.last
      @assessment = @family.assessments.new(default: default?)
      # authorize(@assessment, :new?, @custom_assessment_setting.try(:id)) if @custom_assessment_setting && current_organization.try(:aht) == false

      if @custom_assessment_setting.present? && (@custom_assessment_setting && !policy(@assessment).create?(@custom_assessment_setting.try(:id)))
        redirect_to family_assessments_path(@family), alert: "#{I18n.t('assessments.index.next_review')} of #{@custom_assessment_setting.custom_assessment_name}: #{date_format(@family.custom_next_assessment_date(nil, @custom_assessment_setting.id))}"
      else
        @assessment.populate_family_domains
      end
    end

    def create
      authorize_client
      @assessment = @family.assessments.new(assessment_params)

      @assessment.default = params[:default]
      if current_organization.try(:aht) == true
        if @assessment.save(validate: false)
          redirect_to family_path(@family), notice: t('.successfully_created')
        else
          render :new
        end
      else
        # authorize(@assessment, :create?, @custom_assessment_setting.try(:id)) if @custom_assessment_setting
        if @assessment.save
          redirect_to family_path(@family), notice: t('.successfully_created')
        else
          flash[:alert] = @assessment.errors.full_messages
          render :new
        end
      end
    end

    def show
    end

    def edit
      @assessment.populate_family_domains
    end

    def update
      params[:assessment][:assessment_domains_attributes].each do |assessment_domain|
        add_more_attachments(assessment_domain.second[:attachments], assessment_domain.second[:id])
      end
      if @assessment.update_attributes(assessment_params)
        @assessment.update(updated_at: DateTime.now)
        @assessment.assessment_domains.update_all(assessment_id: @assessment.id)
        redirect_to family_assessment_path(@family, @assessment), notice: t('.successfully_updated')
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
        if @assessment.destroy
          redirect_to family_assessments_path(@assessment.family), notice: t('.successfully_deleted_assessment')
        else
          messages = @assessment.errors.full_messages.uniq.join('\n')
          redirect_to [@family, @assessment], alert: messages
        end

      end
    end

    private

    def find_family
      @family = Family.accessible_by(current_ability).find(params[:family_id])
    end

    def find_assessment
      @assessment = @family.assessments.find(params[:id]).decorate
    end

    def authorize_client
      authorize @family, :create?
    end

    def assessment_params
      default_params = params.require(:assessment).permit(:default, :assessment_date, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last])
      default_params = params.require(:assessment).permit(:default, :assessment_date, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last, attachments: []]) if action_name == 'create'
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
      @family_custom_domains = Domain.family_custom_csi_domains
    end
  end
end
