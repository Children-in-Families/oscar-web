module Api
  module V1
    class CustomDataController < Api::V1::BaseApiController
      def show
        custom_data = CustomData.first
        render json: custom_data || {}
      end
    end
  end
end
