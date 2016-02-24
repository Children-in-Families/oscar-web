module Api
  class AssessmentsController < BaseApiController
    before_action :set_kinship_or_foster_care_case, only: [:create]

    def create
      assessment = @kinship_or_foster_care_case.assessments.new(assessment_params)

      if assessment.save
        render json: { notice: 'Assessment was successfully created.', id: assessment.id }
      else
        render json: assessment.errors, status: :unprocessable_entity
      end
    end

    private

    def set_kinship_or_foster_care_case
      @kinship_or_foster_care_case = KinshipOrFosterCareCase.find(params[:kinship_or_foster_care_case_id])
    end

    def assessment_params
      params.require(:assessment).permit(:case_worker_id, assessment_domains_attributes: [:id, :note, :score, :reason, :domain_id])
    end
  end
end
