module Api
  module V1
    class CarePlansController < Api::V1::BaseApiController
      before_action :find_client
      before_action :find_care_plan, except: :index

      def index
        care_plans = @client.care_plans
        render json: care_plans
      end

      def show
        render json: @care_plan
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
        params.require(:care_plan).permit(:assessment_id, :client_id, :completed, goals_attributes: [:id, :assessment_domain_id, :assessment_id, :description, :_destroy, { tasks_attributes: [:id, :domain_id, :name, :expected_date, :relation, :_destroy] }])
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
