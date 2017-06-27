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
        assessment = @client.assessments.find(params[:id])
        if assessment.update_attributes(assessment_params)
          assessment.update(updated_at: DateTime.now)
          render json: assessment
        else
          render json: assessment.errors, status: :unprocessable_entity
        end
      end

      private

      def assessment_params
        params.require(:assessment).permit(assessment_domains_attributes: [:id, :domain_id, :score, :reason, :goal])
      end
    end
  end
end
