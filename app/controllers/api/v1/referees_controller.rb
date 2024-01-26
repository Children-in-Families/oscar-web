module Api
  module V1
    class RefereesController < Api::V1::BaseApiController
      def index
        render json: Referee.order(:name)
      end
    end
  end
end
