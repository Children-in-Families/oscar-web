module Api
  module V1
    class AgenciesController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Agency.order(:name)
      end
    end
  end
end
