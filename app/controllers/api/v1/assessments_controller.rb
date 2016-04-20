module Api
  module V1
    class AssessmentsController < Api::V1::BaseApiController
      before_action :find_client

      def create
        assessment = @client.assessments.new(assessment_params)

        if assessment.save
          render json: { id: assessment.id }
        else
          render json: assessment.errors, status: :unprocessable_entity
        end
      end

      private

      def assessment_params
        params.require(:assessment).permit(assessment_domains_attributes: [:id, :domain_id, :score, :reason])
      end
    end
  end
end