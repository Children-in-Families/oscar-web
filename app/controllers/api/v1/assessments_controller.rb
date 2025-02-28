module Api
  module V1
    class AssessmentsController < Api::V1::BaseApiController
      include AssessmentConcern

      before_action :find_client
      before_action :find_assessment, only: [:create, :update, :show, :destroy, :upload_attachment]

      def index
        assessments = @client.assessments.includes(:case_notes)
        render json: assessments
      end

      def show
        assessment = @client.assessments.find(params[:id])
        render json: assessment
      end

      def create
        @assessment.default = assessment_params[:custom_assessment_setting_id].blank?
        @assessment.skip_assessment_domain_populate = true

        if Organization.current.try(:aht) == true
          case_conference = CaseConference.find(assessment_params[:case_conference_id])
          if case_conference.assessment.nil? && @assessment.save(validate: false)
            render json: @assessment
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

            render json: assessment
          else
            render json: assessment.errors, status: :unprocessable_entity
          end
        else
          render json: @assessment
        end
      end

      def update
        params[:assessment][:assessment_domains_attributes].each do |_, assessment_domain|
          add_more_attachments(assessment_domain[:attachments], assessment_domain[:id]) if assessment_domain.key?(:id)
        end

        attributes = assessment_params.merge(last_auto_save_at: DateTime.now)
        saved = false
        if params[:draft].present?
          @assessment.assign_attributes(attributes)
          PaperTrail.without_tracking { @assessment.save(validate: false) }

          saved = true
        else
          saved = @assessment.update_attributes(attributes.merge(draft: false))
          @assessment.run_callbacks(:commit)
        end

        if saved
          create_bulk_task(params[:task], @assessment) if params.key?(:task)
          render json: @assessment
        else
          render json: @assessment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if params[:file_index].present?
          remove_attachment_at_index(params[:file_index].to_i)
        end

        head 204 if Assessment.find(params[:id]).destroy
      end

      private

      def assessment_params
        default_params = params.require(:assessment).permit(:default, :assessment_date, :case_conference_id, :custom_assessment_setting_id, :level_of_risk, :description, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last])
        default_params = params.require(:assessment).permit(:default, :assessment_date, :case_conference_id, :custom_assessment_setting_id, :level_of_risk, :description, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, :goal_required, :required_task_last, attachments: []]) if action_name == 'create'
        default_params
      end

      def find_assessment
        @assessment = Assessment.unscoped do
          if params[:id] == 'draft'
            @custom_assessment_setting = find_custom_assessment_setting
            @client.find_or_create_assessment(default: assessment_params[:default], case_conference_id: params[:case_conference], custom_assessment_setting_id: @custom_assessment_setting.try(:id))
          else
            @client.assessments.find(params[:id])
          end
        end
      end

      def remove_attachment_at_index(index)
        assessment_domain = AssessmentDomain.find(params[:assessment_domain])
        remain_attachment = assessment_domain.attachments
        deleted_attachment = remain_attachment.delete_at(index)
        deleted_attachment.try(:remove!)
        remain_attachment.empty? ? assessment_domain.remove_attachments! : (assessment_domain.attachments = remain_attachment)
        message = t('.fail_delete_attachment') unless assessment_domain.save
      end
    end
  end
end
