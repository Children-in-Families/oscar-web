module Api
  module V1
    class ClientEnrollmentTrackingsController < Api::V1::BaseApiController

      before_action :find_client, :find_enrollment
      before_action :find_client_enrollment_tracking, only: :update

      def create
        @client_enrollment_tracking = @enrollment.client_enrollment_trackings.new(client_enrollment_tracking_params)

        if @client_enrollment_tracking.save
          render json: @client_enrollment_tracking
        else
          render json: @client_enrollment_tracking.errors, status: :unprocessable_entity
        end
      end

      def update
        if @client_enrollment_tracking.update_attributes(client_enrollment_tracking_params)
          render json: @client_enrollment_tracking
        else
          render json: @client_enrollment_tracking.errors, status: :unprocessable_entity
        end
      end

      def show
      end

      private

      def client_enrollment_tracking_params
        params.require(:client_enrollment_tracking).permit({}).merge(properties: params[:client_enrollment_tracking][:properties], tracking_id: params[:tracking_id])
      end

      def find_client
        @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
      end

      def find_enrollment
        @enrollment = @client.client_enrollments.find params[:client_enrollment_id]
      end

      def find_client_enrollment_tracking
        @client_enrollment_tracking = @enrollment.client_enrollment_trackings.find params[:id]
      end
    end
  end
end
