module Api
  module V2
    class ProvincesController < Api::V1::BaseApiController
      def index
        render json: Province.order(:name)
      end
    end
  end
end
