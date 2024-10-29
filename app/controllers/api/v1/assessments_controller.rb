module Api
  module V1
    class AssessmentsController < Api::V1::BaseApiController
      include AssessmentConcern

      before_action :find_client

      def index
        assessments = @client.assessments.includes(:case_notes)
        render json: assessments
      end

      def show
        assessment = @client.assessments.find(params[:id])
        render json: assessment
      end

      def create
        assessment = @client.assessments.new(assessment_params)
        assessment.default = assessment_params[:custom_assessment_setting_id].blank?
        assessment.skip_assessment_domain_populate = true
        if assessment.save
          render json: assessment
        else
          render json: assessment.errors, status: :unprocessable_entity
        end
      end

      def update
        params[:assessment][:assessment_domains_attributes].each do |_, assessment_domain|
          add_more_attachments(assessment_domain[:attachments], assessment_domain[:id]) if assessment_domain.key?(:id)
        end

        assessment = @client.assessments.find(params[:id])
        if assessment.update_attributes(assessment_params)
          assessment.update(updated_at: DateTime.now)
          render json: assessment
        else
          render json: assessment.errors, status: :unprocessable_entity
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
