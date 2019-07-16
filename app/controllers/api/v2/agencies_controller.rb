module Api
  module V2
    class AgenciesController < Api::V1::BaseApiController
      def index
        render json: Agency.order(:name)
      end
    end
  end
end
