module Api
  module V1
    class CarePlansController < Api::V1::BaseApiController
<<<<<<< HEAD
      include CreateNestedValue

      before_action :find_client
      before_action :find_care_plan, except: [:index, :create]
=======
      before_action :find_client, :find_care_plan
>>>>>>> 2087d4c2a (API V1 Update)

      def index
        care_plans = @client.care_plans
        render json: care_plans
      end

      def show
        render json: @care_plan
      end

<<<<<<< HEAD
      def create
        care_plan = @client.care_plans.new(care_plan_params)
        assessment = Assessment.find(care_plan.assessment_id)
        if assessment.care_plan.nil? && care_plan.save
          render json: care_plan
        else
          render json: care_plan.errors, status: :unprocessable_entity
        end
      end

=======
>>>>>>> 2087d4c2a (API V1 Update)
      def update
        if @care_plan.update_attributes(care_plan_params)
          render json: @care_plan
        else
          render json: @care_plan.errors, status: :unprocessable_entity
        end
      end

      private

      def care_plan_params
<<<<<<< HEAD
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
=======
        params.require(:care_plan).permit(:assessment_id, :client_id, :completed, goals_attributes: [:id, :assessment_domain_id, :assessment_id, :description, :_destroy, tasks_attributes: [:id, :domain_id, :name, :expected_date, :relation, :_destroy]])
>>>>>>> 2087d4c2a (API V1 Update)
      end

      def find_client
        @client = Client.find(params[:client_id])
      end

      def find_care_plan
        @care_plan = @client.care_plans.find(params[:id])
      end
    end
  end
end
