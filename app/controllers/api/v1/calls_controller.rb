module Api
  module V1
    class CallsController < Api::V1::BaseApiController
      def create
        call = Call.new(call_params)
        if call.save
          render json: call
        else
          render json: call.errors, status: :unprocessable_entity
        end
      end

      private

      def call_params
        params.require(:call).permit(:phone_call_id, :receiving_staff_id,
                                :start_datetime, :end_datetime, :call_type
                                )
      end
    end
  end
end
