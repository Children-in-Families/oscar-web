module Api
  module V1
    class QuantitativeTypesController < Api::V1::BaseApiController
      def index
        render json: QuantitativeType.includes(:quantitative_cases)
      end
    end
  end
end
