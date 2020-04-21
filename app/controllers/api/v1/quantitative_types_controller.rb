module Api
  module V1
    class QuantitativeTypesController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: QuantitativeType.all
      end
    end
  end
end
