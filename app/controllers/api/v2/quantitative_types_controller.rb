module Api
  module V2
    class QuantitativeTypesController < Api::V1::BaseApiController
      def index
        render json: QuantitativeType.all
      end
    end
  end
end
