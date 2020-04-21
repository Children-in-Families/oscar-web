module Api
  module V1
    class AgenciesController < Api::V1::BaseApiController

      def index
        render json: Agency.order(:name)
      end
    end
  end
end
