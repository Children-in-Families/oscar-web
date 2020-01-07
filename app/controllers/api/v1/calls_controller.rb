module Api
  module V1
    class CallsController < Api::ApplicationController

      def index
        calls = Call.order(created_at: :desc)
        render json: calls
      end

      def create
        call = Call.new(call_params)
        if call.save
          render json: call
        else
          render json: call.errors, status: :unprocessable_entity
        end
      end

      def show
        if call
          render json: call
        else
          render json: call.errors
        end
      end

      private

      def call_params
        # binding.pry
        params.require(:call).permit(:phone_call_id, :receiving_staff_id,
                                :start_datetime, :end_datetime, :call_type
                                )
      end

      def call
        @call ||= Call.find(params[:id])
      end
    end
  end
end
