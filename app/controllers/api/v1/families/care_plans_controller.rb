module Api
  module V1
    class Families::CarePlansController < Api::V1::BaseApiController
      include CreateNestedValue

      before_action :set_family
      before_action :find_care_plan, except: [:index, :create]

      def index
        care_plans = @family.care_plans
        render json: care_plans
      end

      def show
        render json: @care_plan
      end

      def create
        care_plan = @family.care_plans.new(care_plan_params)
        assessment = Assessment.find(care_plan.assessment_id)
        if assessment.care_plan.nil? && care_plan.save
          render json: care_plan
        else
          render json: care_plan.errors, status: :unprocessable_entity
        end
      end

      def update
        if @care_plan.update_attributes(care_plan_params)
          render json: @care_plan
        else
          render json: @care_plan.errors, status: :unprocessable_entity
        end
      end

      private

      def care_plan_params
        params.require(:care_plan).permit(
          :assessment_id, :client_id, :care_plan_date, :completed,
          goals_attributes: [
            :id, :assessment_domain_id, :assessment_id, :description, :_destroy,
            {
              tasks_attributes: [
                :id, :domain_id, :name, :expected_date, :relation, :user_id, :client_id, :family_id, :previous_id, :goal_id, :_destroy
              ]
            }
          ]
        )
      end

      def set_family
        @family = Family.accessible_by(current_ability).find(params[:family_id])
      end

      def find_care_plan
        @care_plan = @family.care_plans.find(params[:id])
      end
    end
  end
end
