module Api
  module V1
    class AssessmentsController < Api::V1::BaseApiController
      before_action :find_client

      def create
        assessment = @client.assessments.new(assessment_params)

        if assessment.save
          render json: assessment
        else
          render json: assessment.errors, status: :unprocessable_entity
        end
      end

      def update
        params[:assessment][:assessment_domains_attributes].each do |assessment_domain|
          add_more_attachments(assessment_domain.second[:attachments], assessment_domain.second[:id])
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
          head 204
        end
      end

      private

      def assessment_params

        default_params = params.require(:assessment).permit(:default, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal])
        default_params = params.require(:assessment).permit(:default, assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal, attachments: []]) if action_name == 'create'
        default_params
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

      def remove_attachment_at_index(index)
        assessment_domain = AssessmentDomain.find(params[:assessment_domain])
        remain_attachment = assessment_domain.attachments
        deleted_attachment = remain_attachment.delete_at(index)
        deleted_attachment.try(:remove!)
        remain_attachment.empty? ? assessment_domain.remove_attachments! : (assessment_domain.attachments = remain_attachment )
        message = t('.fail_delete_attachment') unless assessment_domain.save
      end

    end
  end
end
