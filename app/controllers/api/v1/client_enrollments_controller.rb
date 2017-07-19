module Api
  module V1
    class ClientEnrollmentsController < Api::V1::BaseApiController

      before_action :find_client
      before_action :find_client_enrollment, only: :update

      def update
        if @client_enrollment.update_attributes(client_enrollment_params)
          render json: @client_enrollment
        else
          render json: @client_enrollment.errors, status: :unprocessable_entity
        end
      end

      def create
        @client_enrollment = @client.client_enrollments.new(client_enrollment_params)
        if @client_enrollment.save
          render json: @client_enrollment
        else
          render json: @client_enrollment.errors, status: :unprocessable_entity
        end
      end

      private

      def client_enrollment_params
        params.require(:client_enrollment).permit(:enrollment_date, {}).merge(properties: params[:client_enrollment][:properties], program_stream_id: params[:program_stream_id])
      end

      def find_client_enrollment
        @client_enrollment = @client.client_enrollments.find(params[:id])
      end

      def find_client
        @client = Client.accessible_by(current_ability).find(params[:client_id])
      end
    end
  end
end
